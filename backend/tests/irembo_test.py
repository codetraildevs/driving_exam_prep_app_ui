"""Disposable MySQL integration checks: validation, ownership, retries, staff and privacy."""
import concurrent.futures, json, os, pathlib, subprocess, time, urllib.request, urllib.error, uuid
ENV={**os.environ,'MYSQL_PWD':'test-password'}
def sql(text):
 return subprocess.check_output(['mysql','-h','127.0.0.1','-u','root','-N','-e',text],env=ENV).decode()
sql('CREATE DATABASE irembo_test; USE irembo_test; CREATE TABLE users (id VARCHAR(36) PRIMARY KEY, name VARCHAR(100), role VARCHAR(10), isBlocked TINYINT DEFAULT 0);'+
    "INSERT INTO users VALUES ('u1','Applicant','USER',0),('u2','Other user','USER',0),('a1','Admin','ADMIN',0),('m1','Manager','MANAGER',0),('blocked','Blocked','MANAGER',1);")
sql('USE irembo_test;'+pathlib.Path('backend/migrations/20261026_irembo.sql').read_text())
server=subprocess.Popen(['php','-S','127.0.0.1:8101','backend/tests/irembo_router.php'],env={**os.environ,'IREMBO_TEST_MODE':'1'},stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
def req(method='GET',path='',body=None,user='u1',expected=200):
 headers={'Content-Type':'application/json'}
 if user: headers['X-Test-User']=user
 request=urllib.request.Request('http://127.0.0.1:8101/api/irembo-requests'+path,data=None if body is None else json.dumps(body).encode(),headers=headers,method=method)
 try: response=urllib.request.urlopen(request,timeout=10)
 except urllib.error.HTTPError as e: response=e
 data=json.load(response)
 assert response.status==expected,(method,path,response.status,data)
 return data.get('data')
def form(**values):
 return {'requestKey':str(uuid.uuid4()),'fullName':'Test Applicant','phoneNumber':'0788123456','nationalId':'0123456789012345','dob':'1990-02-01','service':'Provisoire','examLanguage':'rw','district':'Gasabo',**values}
try:
 for _ in range(50):
  try: req();break
  except urllib.error.URLError: time.sleep(.1)
 else: raise AssertionError('test server unavailable')
 req(user=None,expected=401);req(user='blocked',expected=403)
 body=form(provisoireCode='must not persist',category='B',permisOption='Manual')
 body['fullName']='É' * 100
 body['userId']='u2' # Untrusted ownership must be ignored.
 first=req('POST',body=body,expected=201)
 assert first['userId']=='u1' and first['fullName']=='É' * 100
 assert first['status']=='Pending' and first['category'] is None and first['provisoireCode'] is None
 assert first['nationalId']=='************2345'
 retry=req('POST',body=body,expected=201);assert first['id']==retry['id']
 req('POST',body={**body,'fullName':'Changed'},expected=409)
 assert req()['total']==1
 req(path='/'+first['id'],user='u2',expected=404)
 req('PUT','/'+first['id'],{'version':1,'status':'Completed'},expected=403)
 req('POST',body=form(),user='a1',expected=403)
 for values in [dict(nationalId='123'),dict(nationalId=1234567890123456),dict(dob='2999-01-01'),dict(dob='2025-02-30'),dict(district='Not a district'),dict(examLanguage='xx'),dict(phoneNumber='abc'),dict(service='Other'),dict(preferredExamDate='not-a-date'),dict(preferredExamDate=0)]:
  req('POST',body=form(**values),expected=400)
 for cat in ['C','A,B','AB',['A','B'],'']:
  req('POST',body=form(service='Permis',permisOption='Manual',provisoireCode='001234',category=cat),expected=400)
 for option in ['Manual','Automatic']:
  req('POST',body=form(service='Permis',permisOption=option,category='A'),expected=400)
 manual=req('POST',body=form(service='Permis',permisOption='Manual',provisoireCode='001234',category=' b '),expected=201)
 assert manual['category']=='B'
 automatic=req('POST',body=form(service='Permis',permisOption='Automatic',provisoireCode='000456'),expected=201)
 assert automatic['category']=='A'
 req('POST',body=form(service='Permis',permisOption='Automatic',provisoireCode='000456',category='B'),expected=400)
 detail=req(path='/'+manual['id'],user='m1');assert detail['nationalId']=='0123456789012345' and detail['provisoireCode']=='001234'
 req('PUT','/'+manual['id'],{'version':1,'status':'Rejected'},user='m1',expected=400)
 changed=req('PUT','/'+manual['id'],{'version':1,'status':'Needs Information','reason':'Please confirm your details','assignedStaffId':'m1','internalNote':'Private staff note\nSecond line','applicantMessage':'Hello applicant'},user='a1')
 assert changed['version']==2
 req('PUT','/'+manual['id'],{'version':1,'status':'Completed'},user='m1',expected=409)
 req('PUT','/'+manual['id'],{'version':2,'assignedStaffId':'u1'},user='m1',expected=400)
 own=req(path='/'+manual['id']);assert 'audit' not in own and all(str(m['applicantVisible'])=='1' for m in own['messages']) and 'Private staff' not in json.dumps(own)
 staff=req(path='/'+manual['id'],user='m1');assert len(staff['audit'])==2 and len(staff['messages'])==3
 req('PUT','/'+manual['id'],{'version':2,'assignedStaffId':'a1','status':'Completed'},user='m1')
 for query in ['?service=Permis&permisOption=Manual&category=B&status=Completed&examLanguage=rw&district=Gasabo&assignedStaffId=a1&sort=updated','?search='+manual['reference'],'?search=Test%20Applicant','?search=0788123456','?assignedStaffId=unassigned','?sort=oldest','?sort=name']:
  listing=req(path=query,user='m1');assert listing['total']>0 and all('*' in r['nationalId'] for r in listing['items'])
 req(path='?sort=sql',user='m1',expected=400)
 req(path='?from=2026-02-01&to=2026-01-01',user='m1',expected=400)
 for _ in range(20):req('POST',body=form(),expected=201)
 listing=req(user='m1');assert listing['total']==23 and len(listing['items'])==20
 assert len(req(path='?page=2',user='m1')['items'])==3
 assert len(req()['items'])==23 # Applicant view includes all own requests, without pagination.
 assert req(user='u2')['total']==0
 # Clear conditional data on service change, preserving historical audit.
 new=req('PUT','/'+automatic['id'],{'version':1,'service':'Provisoire'},user='m1')
 assert new['category'] is None and new['permisOption'] is None and new['provisoireCode'] is None
 # Database role is authoritative even if a stale token claims staff privileges.
 sql("USE irembo_test; UPDATE users SET role='USER' WHERE id='m1';")
 req(path='/'+first['id'],user='m1',expected=404)
 sql('USE irembo_test; RENAME TABLE irembo_requests TO irembo_requests_backup;')
 req(expected=503)
 print('PASS: all service paths, conditional fields, privacy, staff scope, retries, filters, pagination, audit and role revocation')
finally:
 server.terminate();server.wait(timeout=5)
