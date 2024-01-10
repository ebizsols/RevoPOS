<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Paket | Revo Kasir</title>
    <meta http-equiv="Content-Type" content="text/html;"/>
    <meta charset="UTF-8">
  	<style media="all">
<?php
  $data = [
    'orders'=>[
      (OBJECT)[
        'product'=>(OBJECT)[
          'name'=>"kursi gaming",
          'sku'=>"kks328",
        ],
        "qty"=>111121
      ],
      (OBJECT)[
        'product'=>(OBJECT)[
          'name'=>"hard case iphone pro michat",
          'sku'=>"kks328",
        ],
        "qty"=>111121
      ],
      (OBJECT)[
        'product'=>(OBJECT)[
          'name'=>"redmi xs max 125gb",
          'sku'=>"kks328",
        ],
        "qty"=>111121
      ],
      (OBJECT)[
        'product'=>(OBJECT)[
          'name'=>"mac-q",
          'sku'=>"kks328",
        ],
        "qty"=>111121
      ],
    ],
    'resi'=>'7124487AF',
    'expedisi'=>'RJE',
    'penerima'=>'Royali',
    'alamat_lengkap'=>'Jl. Darmo Kali Mas Mojoroto Bliwang',
    'pengirim'=>'Pablo',
    'nohp_pengirim'=>'076558901+87',
    'nohp_penerima'=>'081234567869',
    'alamat_pengirim'=>'Texas Holdem Poker',
    'alamat_pelanggan'=>'Jl. Gajayana Pesisir Pantai Kuyang',
    'kota_pelanggan'=>'Don Bosco Melbourne',
    'kecamatan_pelanggan'=>'Sugiharjo',
    'berat_produk'=>'gaberat',
    'no_inv'=>'0987658790oj'
  ];

  $from = 'api';

  if($from == 'api'){
   $max = "100%";
   $display= "block";
   $min = "100%";
   $wrap="nowrap";
   $size="18cm";
   $size_height="28cm";
   $padding_qr="20px 10px 5px 10px";
   $size_qr="25%";
   $padding_layout="10px";
   $font_size="23px";
  }else{
    $max = "50%";
    $display= "block";
    $min = "0%";
    $wrap="nowrap";
    $size="21cm";
    $size_height="23cm";
    $padding_qr="10px 1px 0px 1px";
    $size_qr="25%";
    $padding_layout="10px";
    $font_size="13px";
  }
?>
		*{
			margin: 0;
			padding: 0;
			line-height: 1.3;
			font-family: sans-serif;
			color: #333542;
		}
		body {
      background: white;
}
page {
  background: white;
  padding:<?= $padding_layout; ?>;
  display: block;
  margin: 0 auto;
  margin-bottom: 0.5cm;
  box-shadow: 0 0 0.5cm rgba(0,0,0,0.5);
}
page[size="A4"] {
  width: <?= $size; ?>;
  height: <?= $size_height; ?>;
}
page[size="A4"][layout="landscape"] {
  width: 29.7cm;
  height: 21cm;
}
page[size="A3"] {
  width: 29.7cm;
  height: 42cm;
}
page[size="A3"][layout="landscape"] {
  width: 42cm;
  height: 29.7cm;
}
page[size="A5"] {
  width: 14.8cm;
  height: 21cm;
}
page[size="A5"][layout="landscape"] {
  width: 21cm;
  height: 14.8cm;
}
@media print {
  body, page {
    margin: 0;
    box-shadow: 0;
  }
}
.row{
    display: flex;
}
.font-bold{
    color: #000 !important;
    font-size: <?= $font_size; ?>;
    font-weight: 600;
    margin:0px;
}
.font-style{
    color: #000 !important;
    font-size: <?= $font_size; ?>;
    font-weight: 400;
    margin:0px;
}
.font-style-uppercase{
  text-transform: uppercase;
  color: #000 !important;
    font-size: <?= $font_size; ?>;
    font-weight: 400;
    margin:0px;
}
.line-style{
  border-bottom: 2px dashed #000;
  border-top: 2px dashed #000;
  margin-bottom: 5px;
  margin-top: 5px;
}
.style-border-div{
  border: 2px solid #000;
    padding: 5px;
}

.layout_style{
  width:100%;
  max-width:<?= $max; ?>;
  display: <?= $display; ?>;
    min-height: <?= $min; ?>;
    flex-wrap: <?= $wrap; ?>;
}
.list_produk{
  width:100%;
  margin-top:5px;
}
.qr_code{
  padding: <?= $padding_qr; ?>;
  width:<?= $size_qr; ?>;
}

	</style>
</head>
<body>
<page size="A4">
  <div class="layout_style">
    <div style="border:2px solid #000;padding:10px 10px 10px 10px">
      <!-- header -->
      <table style="width:100%">
        <tr>
          <th class="font-style">Resi : <?php echo $data['resi'] ?> </th>
          <th class="font-style" style="text-align:right">Ekspedisi : <?= $data['expedisi'] ?></th>
        </tr>
      </table>
      <!-- barcode image -->
      <div style="padding:10px" class="line-style">
      <table style="width:100%" >
        <tr>
          <th class="font-style" style="text-align:center"><img style="width:70%" src="data:image/png;base64, {!! $barcode !!}"/></th>
        </tr>
      </table>
      </div>
      <!-- user & address -->
      <div class="row" style="padding:5px 10px 5px 10px">
        <table style="width:100%">
          <tr style="vertical-align: top;">
            <th class="font-style" style="width:50%">
              <p class="font-bold">Penerima : <?php echo $data['penerima'] ?></p>
                <p style="margin-bottom:5px" class="font-style"><?php echo $data['nohp_penerima'] ?></p>
                <p class="font-style"><?php echo htmlspecialchars($data['alamat_lengkap']) ?></p>
            </th>
            <th class="font-style" style="text-align:right;">
              <p class="font-bold">Pengirim : <?php echo $data['pengirim'] ?></p>
              <p style="margin-bottom:5px" class="font-style"><?php echo $data['nohp_pengirim'] ?></p>
              <p class="font-style"><?php echo $data['alamat_pengirim'] ?></p>
            </th>
          </tr>
        </table>
      </div>
      <div class="row" style="text-align: center;padding:5px 10px 10px 10px">
        <table style="width:100%">
          <tr style="vertical-align: top;">
            <th class="font-style" style="padding: 1px;text-align:center">
              <div class="style-border-div">
                <p class="font-style-uppercase"><?php echo $data['alamat_pelanggan'] ?></p>
              </div>
            </th>
            <th class="font-style" style="padding: 1px;text-align:center">
              <div class="style-border-div">
                <p class="font-style-uppercase"><?php echo $data['kota_pelanggan'] ?></p>
              </div>
            </th>
            <th class="font-style" style="padding: 1px;text-align:center">
              <div class="style-border-div">
                <p class="font-style-uppercase"><?php echo $data['kecamatan_pelanggan'] ?></p>
              </div>
            </th>
          </tr>
        </table>
      </div>
      <div class="row" style="text-align: center;padding:0px 10px 10px 10px">
        <table style="width:100%">
          <tr style="vertical-align: top;">
            <th class="font-style" style="padding: 1px;text-align:center">
              <div class="style-border-div">
                <p class="font-style-uppercase">Cashless</p>
              </div>
            </th>
            <th class="font-style" style="padding: 1px;text-align:center">
              <div class="style-border-div">
              <p style="font-style: italic;" class="font-style">Penjual tidak perlu bayar ongkir di kurir </p>
              </div>
            </th>
          </tr>
        </table>
      </div>
      <!-- delivery order -->
      <div class="row" style="padding:10px 10px 5px 10px;">
        <table style="width:100%">
          <tr style="vertical-align: top;">
            <th class="font-style" style="padding: 1px;width:70%">
            <table style="width:100%">
              <tr style="vertical-align: top;">
                <th>
                <div>
                  <p class="font-style">Berat : <?php echo $data['berat_produk'] ?> gr</p>
                  </div>
                </th>
                <th>
                <div>
                  <p class="font-style">COD : Rp0</p>
                  </div>
                <th>
              </tr>
            </table>
            <table style="width:100%">
              <tr style="vertical-align: top;">
                <th class="font-style" style="width:100%">
                <p class="font-style">No. Pesanan : <?php echo $data['no_inv'] ?></p>
                </th>
              </tr>
            </table>
            </th>
            <th class="font-style qr_code" >
              <div>
              <img style="width:100%" src="data:image/png;base64, {!! $resicode !!}"/>
              </div>
            </th>
          </tr>
        </table>
      </div>
    </div>
    <!-- batas div border -->
    <!-- list product -->
    <div class="list_produk">
      <table style="width:100%">
        <tr style="border-bottom: 1px solid #000;">
          <th class="font-bold">#</th>
          <th class="font-bold">Nama Produk</th>
          <th class="font-bold">SKU</th>
          <th class="font-bold">QTY</th>
        </tr>
        <?php
          $orders = [
            (OBJECT)[
              'product'=>(OBJECT)[
                'name'=>"kura2 nakal",
                'sku'=>"kks328",
              ],
              "qty"=>111121
            ],
          ];
         ?>
          <?php foreach ($data['orders'] as $key => $orderDetail): ?>
            <?php
              $pname = $orderDetail->product != null ? $orderDetail->product->name : "N/A";
              $sku = $orderDetail->product->sku;
              $qty = $orderDetail->qty;
             ?>
            <tr style="border-bottom: 1px solid #000;">
              <td class="font-style"><?php echo ++$key; ?></td>
              <td class="font-style"><?php echo $pname ?></td>
              <td class="font-style"><?php echo $sku ?></td>
              <td class="font-style"><?php echo $qty ?></td>
            </tr>
          <?php endforeach; ?>
      </table>
    </div>
  </div>
</page>
</body>
</html>
