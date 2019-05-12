<?php

$file = fopen('/var/log/dokuwiki.log', 'a');

fputs($file, date("[Y-m-d H:i:s] RSS Feed access\n"));

$memcached = new Memcached();
$memcached->addServer('127.0.0.1', '11211');
$items = $memcached->get('dokuwiki_data');

if(!$items) {
	fputs($file, date("[Y-m-d H:i:s] Fetching update data\n"));

	$curl = curl_init();
	curl_setopt($curl, CURLOPT_URL, 'http://update.dokuwiki.org/check/');
	curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
	$data = curl_exec($curl);
	$info = curl_getinfo($curl);
	curl_close($curl);

	if($info['http_code'] != 200) {
		die('Error while fetching update data for dokuwiki');
	}

	$items = explode('%', $data);

	foreach($items as $item) {
		$memcached->set('dokuwiki_data', $items, 86400);
	}

	fputs($file, date("[Y-m-d H:i:s] Fetching completed\n"));
}

$output = array();
$feed_date = 0;
foreach($items as $item) {
	if(trim($item) == '') {
		continue;
	}
	$title = preg_replace('/<[^>]+>/', '', $item);
	if(($pos = mb_strpos($title, '.', 0, 'UTF-8')) !== false) {
		$title = mb_substr($title, 0, $pos+1, 'UTF-8');
	}

	preg_match('/([0-9]{4}-[0-9]{2}-[0-9]{2})/', $item, $matches);
	if(!isset($matches[1])) {
		continue;
	}
	$timestamp = strtotime($matches[1]);

	$output[] = array(
		'title' => trim($title),
		'link' => 'http://www.splitbrain.org/go/dokuwiki',
		'guid' => md5($item),
		'description' => trim($item),
		'timestamp' => $timestamp
	);
	$feed_date = max($feed_date, $timestamp);
}

fclose($file);

header('Content-Type: application/rss+xml; charset=UTF-8');

?>
<?php echo '<?xml version="1.0" encoding="UTF-8" ?>'; ?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
<channel>
  <title>Dokuwiki updates</title>
  <link>https://rueckgr.at/~paulchen/dokuwiki_updates.php</link>
  <atom:link href="https://rueckgr.at/~paulchen/dokuwiki_updates.php" rel="self" type="application/rss+xml" />
  <description>Dokuwiki updates</description>
  <pubDate><?php echo date(DateTime::RSS, $feed_date) ?></pubDate>
  <?php foreach($output as $item): ?>
    <item>
      <title><![CDATA[<?php echo htmlspecialchars($item['title'], ENT_NOQUOTES, 'UTF-8'); ?>]]></title>
      <link><?php echo $item['link'] ?></link>
      <guid isPermaLink="false"><?php echo $item['guid'] ?></guid>
      <pubDate><?php echo date(DateTime::RSS, $item['timestamp']) ?></pubDate>
      <description><![CDATA[<?php echo $item['description'] ?>]]></description>
    </item>
  <?php endforeach; ?>
</channel>

</rss>
