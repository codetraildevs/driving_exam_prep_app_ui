<!doctype html>
<html lang="<?= $escape($language) ?>">
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="robots" content="noindex"><title>Rwanda Traffic Rules · Invitation</title>
<style>
*{box-sizing:border-box}body{margin:0;background:#f5f5f8;color:#202038;font:16px/1.65 system-ui,sans-serif;min-height:100vh;display:grid;place-items:center;padding:24px}
main{max-width:540px;background:white;border-radius:28px;padding:clamp(24px,6vw,48px);box-shadow:0 18px 60px #46206a12}
.brand{color:#602c91;font-weight:750;letter-spacing:.04em}h1{font-size:clamp(28px,6vw,38px);line-height:1.18;letter-spacing:-.03em}p{color:#55566a}a.button{display:block;background:#602c91;color:white;padding:15px 20px;border-radius:14px;text-align:center;text-decoration:none;font-weight:650;margin:28px 0}small{display:block;color:#6b7280}.note{border-top:1px solid #eceaf1;margin-top:24px;padding-top:20px;font-size:13px}nav{display:flex;gap:16px}nav a{color:#602c91}
</style>
<main><div class="brand">RWANDA TRAFFIC RULES</div><h1><?= $escape($copy[0]) ?></h1>
<p><?= $escape($valid ? $copy[1] : $copy[5]) ?></p>
<a class="button" href="<?= $escape($play) ?>"><?= $escape($copy[2]) ?></a>
<?php if ($valid): ?><small><?= $escape($copy[3]) ?></small><p class="note"><?= $escape($copy[4]) ?></p><?php endif ?>
<p class="note"><?= $escape($copy[6]) ?></p>
<nav aria-label="Language"><?php foreach (['en'=>'English','fr'=>'Français','rw'=>'Kinyarwanda'] as $lang=>$label): ?>
<a href="?<?= $escape(http_build_query(['code'=>is_string($code) ? $code : '', 'lang'=>$lang])) ?>"><?= $escape($label) ?></a>
<?php endforeach ?></nav></main></html>
