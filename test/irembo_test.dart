import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_rule_in_rwanda/features/irembo/data/irembo_repository.dart';
Map<String,dynamic> data()=>{'fullName':'Test Driver','phoneNumber':'0788123456','nationalId':'0123456789012345','dob':'1990-01-01','service':'Provisoire','examLanguage':'rw','district':'Gasabo'};
void main(){
  test('all three paths enforce their conditional fields',(){
    expect(IremboRules.validate(data()),isNull);
    final manual={...data(),'service':'Permis','permisOption':'Manual','provisoireCode':'001234','category':' b '};
    expect(IremboRules.validate(manual),isNull);
    expect(IremboRules.applicable(manual)['category'],'B');
    for(final category in ['C','AB','A,B','','A F'])expect(IremboRules.validate({...manual,'category':category}),'category');
    expect(IremboRules.validate({...manual,'provisoireCode':''}),'provisoireCode');
    expect(IremboRules.validate({...manual,'permisOption':'Automatic','category':'B'}),'category');
    expect(IremboRules.validate({...manual,'permisOption':'Automatic','category':'A'}),isNull);
    final provisoire=IremboRules.applicable({...manual,'service':'Provisoire'});
    expect(provisoire.containsKey('category'),isFalse);
    expect(provisoire.containsKey('permisOption'),isFalse);
    expect(provisoire.containsKey('provisoireCode'),isFalse);
  });
  test('validates dates, national IDs and the exact district list',(){
    expect(IremboRules.districts.length,24);
    expect(IremboRules.districts.toSet().length,24);
    for(final d in IremboRules.districts)expect(IremboRules.validate({...data(),'district':d}),isNull);
    for(final id in ['123','12345678901234567','123456789012345x'])expect(IremboRules.validate({...data(),'nationalId':id}),'nationalId');
    expect(IremboRules.validate({...data(),'district':'Unknown'}),'district');
    expect(IremboRules.validate({...data(),'dob':'2999-01-01'}),'dob');
    expect(IremboRules.validate({...data(),'dob':'2025-02-30'}),'dob');
    expect(IremboRules.validate({...data(),'preferredExamDate':'not a date'}),'preferredExamDate');
    expect(IremboRules.validate({...data(),'examLanguage':'de'}),'examLanguage');
  });
  test('preserves leading zeros and normalizes supported phone formats',(){
    final normalized=IremboRules.applicable({...data(),'phoneNumber':'+250 788 123 456','service':'Permis','permisOption':'Manual','provisoireCode':'000012','category':' a '});
    expect(normalized['phoneNumber'],'0788123456');
    expect(normalized['nationalId'],'0123456789012345');
    expect(normalized['provisoireCode'],'000012');
    expect(normalized['category'],'A');
    expect(IremboRules.validate(normalized),isNull);
  });
  test('retry keys are unique UUID v4 values',(){
    final ids=List.generate(100,(_)=>IremboRepository.newKey());
    expect(ids.toSet().length,100);
    for(final id in ids)expect(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$').hasMatch(id),isTrue);
  });
}
