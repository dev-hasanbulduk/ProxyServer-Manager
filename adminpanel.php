<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Sunucu bilgileri
$host = '23.160.201.228';  // Bu artık kullanılmayacak
$port = 22;  // Bu artık kullanılmayacak
$username = 'root';  // Bu artık kullanılmayacak
$password = 'xhasan123!diyo@';  // Bu artık kullanılmayacak

// Form gönderildiyse
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    if (isset($_POST['action']) && $_POST['action'] == 'create') {
        // Hesap ekleme formundan gelen veriler
        $user = $_POST['user'];
        $pass = $_POST['pass'];
        $port = $_POST['port'];
        $protocol = $_POST['protocol'];
        $ip = $_POST['ip'];
        $gun = $_POST['gun'];

        // Komutu oluştur
        $command = "sudo bash /root/ipv4.sh '$ip' $user $pass $protocol $port 1.1.1.1 $gun";

        // Komutu çalıştır
        $output = shell_exec($command);
        
        if ($output === null) {
            die('Komut çalıştırılamadı');
        }

        echo "<h2>Hesap Ekleme Çıktısı:</h2><pre>" . htmlspecialchars($output, ENT_QUOTES, 'UTF-8') . "</pre>";

    } elseif (isset($_POST['action']) && $_POST['action'] == 'delete') {
        // Hesap silme formundan gelen veri
        $serial = $_POST['serial'];

        // Komutu oluştur
        $command = "sudo bash /root/delete.sh $serial";

        // Komutu çalıştır
        $output = shell_exec($command);

        if ($output === null) {
            die('Komut çalıştırılamadı');
        }

        echo "<h2>Hesap Silme Çıktısı:</h2><pre>" . htmlspecialchars($output, ENT_QUOTES, 'UTF-8') . "</pre>";
    }
}
?>

<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Form gönderildiyse
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    if (isset($_POST['action']) && $_POST['action'] == 'create') {
        // Hesap ekleme formundan gelen veriler
        $user = $_POST['user'];
        $pass = $_POST['pass'];
        $port = $_POST['port'];
        $protocol = $_POST['protocol'];
        $ip = $_POST['ip'];
        $gun = $_POST['gun'];

        // Komutu oluştur
        $command = "bash /root/ipv4.sh '$ip' $user $pass $protocol $port 1.1.1.1 $gun";

        // Komutu çalıştır
        $output = shell_exec($command);

        echo "<h2>Hesap Ekleme Çıktısı:</h2><pre>" . htmlspecialchars($output, ENT_QUOTES, 'UTF-8') . "</pre>";
        
    }
}

// Dosya yolu
$filename = isset($_POST['filename']) ? $_POST['filename'] : '';
$days = isset($_POST['days']) ? intval($_POST['days']) : 0;

// Dosya içeriğini oku ve güncelle
if (!empty($filename)) {
    $filePath = '/opt/3proxy/expiration/' . $filename;

    if (file_exists($filePath)) {
        // Dosyayı oku
        $fileContent = file_get_contents($filePath);

        // Dosya içeriğini güncelle
        $newContent = [];
        $lines = explode("\n", $fileContent);
        foreach ($lines as $line) {
            $parts = explode(' ', $line);
            
            // Satırın tarih kısmını ve kod kısmını al
            if (count($parts) === 3) {
                $date = $parts[0];
                $code = $parts[2];
                
                // Yeni kalan gün sayısını oluştur
                $newLine = $date . ' ' . $days . ' ' . $code;
                
                // Güncellenmiş satırı diziye ekle
                $newContent[] = $newLine;
            }
        }

        // Güncellenmiş içeriği dosyaya yaz
        $updatedContent = implode("\n", $newContent);
        file_put_contents($filePath, $updatedContent);
    }
}
?>

<?php
$directory = '/opt/3proxy/user_info';
$searchTerm = isset($_POST['search']) ? $_POST['search'] : '';

// Dosya ve içeriklerini listeleme
$files = scandir($directory);
$results = [];

// Arama işlemi
if ($searchTerm) {
    foreach ($files as $file) {
        // Geçersiz dosyaları atla
        if ($file === '.' || $file === '..') continue;

        $filePath = $directory . '/' . $file;
        // Dosya içeriklerini oku
        $content = file_get_contents($filePath);

        // Arama terimini dosya adı ve içeriklerinde kontrol et
        if (stripos($file, $searchTerm) !== false || stripos($content, $searchTerm) !== false) {
            $results[] = [
                'name' => $file,
                'content' => $content
            ];
        }
    }
}
?>
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <title>Yönetim Paneli</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
        }
        .container {
            width: 80%;
            margin: auto;
            padding: 20px;
            background: #fff;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        h1 {
            margin-top: 0;
        }
        form {
            margin-top: 20px;
        }
        input[type="submit"] {
            background-color: #4CAF50;
            color: white;
            border: none;
            padding: 10px;
            border-radius: 4px;
            cursor: pointer;
        }
        input[type="submit"]:hover {
            background-color: #45a049;
        }
        body {
            font-family: Arial, sans-serif;
        }
        form {
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin: 5px 0;
        }
        input, select {
            padding: 5px;
            margin-bottom: 10px;
            width: 300px;
        }
        input[type="submit"] {
            width: auto;
            background-color: #4CAF50;
            color: white;
            border: none;
            cursor: pointer;
        }
        input[type="submit"]:hover {
            background-color: #45a049;
        }
        pre {
            background-color: #f4f4f4;
            padding: 10px;
            border: 1px solid #ddd;
            overflow: auto;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        table, th, td {
            border: 1px solid black;
        }
        th, td {
            padding: 8px;
            text-align: left;
            vertical-align: top; /* Verileri üstten hizalar */
        }
    </style>
</head>
<body>

    <div class="container">

        <h1>Hesap Ekleme ve Silme</h1>

        <!-- Hesap Ekleme Formu -->
        <form method="post" action="">
            <input type="hidden" name="action" value="create">
            <label for="protocol">Protokol:</label>
            <select id="protocol" name="protocol">
                <option value="proxy">Proxy</option>
                <option value="socks">Socks</option>
            </select>
            <br>
            <label for="user">Kullanıcı Adı:</label>
            <input type="text" id="user" name="user" required>
            <br>
            <label for="pass">Şifre:</label>
            <input type="password" id="pass" name="pass" required>
            <br>
            <label for="port">Port:</label>
            <input type="text" id="port" name="port" required>
            <br>
            <label for="ip">IP Adresi:</label>
            <input type="text" id="ip" name="ip" required>
            <br>
            <label for="gun">Gün:</label>
            <input type="text" id="gun" name="gun" required>
            <br>
            <input type="submit" value="Hesap Ekle">
        </form>

        <hr>

        <!-- Hesap Silme Formu -->
        <h2>Hesap Silme</h2>
        <form method="post" action="">
            <input type="hidden" name="action" value="delete">
            <label for="serial">Serial Key:</label>
            <input type="text" id="serial" name="serial" required>
            <br>
            <input type="submit" value="Hesap Sil">
        </form>

    </div>
<div class="container">

        <table>
            <thead>
                <tr>
                    <th>Hesap Sorgulama</th>
                    <th>Proxy Gün Sorgulama ve Ekleme</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>
                        <form method="post" action="">
                        						    <h1>Dosya Arama</h1>
    <form method="post">
        <input type="text" name="search" placeholder="Arama terimini girin" value="<?php echo htmlspecialchars($searchTerm); ?>">
        <button type="submit">Ara</button>
    </form>

    <h2>Sonuçlar:</h2>
    <ul>
        <?php if ($results): ?>
            <?php foreach ($results as $result): ?>
                <li>
                    <strong><?php echo htmlspecialchars($result['name']); ?></strong><br>
                    <pre><?php echo htmlspecialchars($result['content']); ?></pre>
                </li>
            <?php endforeach; ?>
        <?php else: ?>
            <li>Hiçbir sonuç bulunamadı.</li>
        <?php endif; ?>
    </ul>
                        </form>
                    </td>
                    <td>
                        <h1>Serial Key ile Kalan Gün Sorgulama</h1>
                        <form method="post" action="">
                            <label for="search">Serial Key:</label>
                            <input type="text" id="search" name="search" required>
                            <input type="submit" value="Gün Sorgula">
                        </form>

                        <?php
                        if ($_SERVER['REQUEST_METHOD'] === 'POST' && !empty($_POST['search'])) {
                            $searchTerm = $_POST['search'];
                            $directory = '/opt/3proxy/expiration';
                            $filePath = "$directory/$searchTerm";

                            if (file_exists($filePath)) {
                                echo "<h2>Bulunan Dosyalar:</h2>";
                                echo "<table>";
                                echo "<thead><tr><th>Dosya Adı</th><th>İçerik</th></tr></thead><tbody>";
                                $fileContent = file_get_contents($filePath);
                                echo "<tr><td>" . htmlspecialchars($searchTerm) . "</td><td class=\"file-content\">" . htmlspecialchars($fileContent) . "</td></tr>";
                                echo "</tbody></table>";
                            } else {
                                echo "<p>Aradığınız dosya bulunamadı.</p>";
                            }
                        }
                        ?>

                        <h2>Gün Ekleme</h2>
                        <form action="" method="post">
                            <label for="filename">Serial Key:</label>
                            <input type="text" id="filename" name="filename" required>
                            <br><br>
                            <label for="days">Yeni Kalan Gün Sayısı:</label>
                            <input type="number" id="days" name="days" min="0" required>
                            <br><br>
                            <input type="submit" value="Güncelle">
                        </form>


						
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</body>
</html>
