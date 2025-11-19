-- Create table with correct column types
CREATE TABLE email_template (
  id BIGSERIAL PRIMARY KEY,
  template_type VARCHAR(32) NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Verify column types (optional check query):
-- SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'email_template' ORDER BY ordinal_position;

-- Sample unpaid template (placeholders: {{name}}, {{amount}}, {{email}}, {{status}}, {{time}})
INSERT INTO email_template (template_type, content) VALUES
('unpaid', '<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Pengingat Pembayaran Uang Kas</title>
</head>
<body style="font-family: Arial, Helvetica, sans-serif; background:#f4f6f8; margin:0; padding:0;">
  <table role="presentation" width="100%" style="max-width:600px;margin:24px auto;background:#ffffff;border-radius:8px;overflow:hidden;box-shadow:0 2px 6px rgba(0,0,0,0.08);">
    <tr>
      <td style="background:linear-gradient(90deg,#4f46e5,#06b6d4);padding:18px 24px;color:#ffffff">
        <h1 style="margin:0;font-size:20px;letter-spacing:0.2px">Pengingat Pembayaran Uang Kas</h1>
      </td>
    </tr>
    <tr>
      <td style="padding:20px 24px;color:#333333">
        <p style="margin:0 0 12px 0;font-size:15px">Halo <strong>{{name}}</strong>,</p>
        <p style="margin:0 0 18px 0;color:#555;line-height:1.4">Ini adalah pengingat bahwa anda memiliki tagihan uang kas:</p>

       <table role="presentation" width="100%" style="margin-bottom:18px;border-collapse:collapse">
          <tr>
            <td style="padding:12px;border:1px solid #eef2ff;background:#fbfdff;width:65%;">Jumlah</td>
            <td style="padding:12px;border:1px solid #eef2ff;background:#fbfdff;width:35%;font-weight:600">{{amount}}</td>
          </tr>
          <tr>
            <td style="padding:12px;border:1px solid #eef2ff;">Status</td>
            <td style="padding:12px;border:1px solid #eef2ff;font-weight:600">{{status}}</td>
          </tr>
        </table>

        <p style="margin:0 0 18px 0;color:#333">Jika Anda sudah melakukan pembayaran, mohon konfirmasi ke bendahara atau balas email ini.</p>

       <p style="margin:0 0 20px 0;text-align:center">
          <!-- Keep anchors inline-block but add bottom margin so when stacked on mobile they have space -->
          <a href="https://web-puce-ten-87.vercel.app/" style="display:inline-block;margin-right:8px;margin-bottom:12px;padding:10px 16px;background:#ef4444;color:#fff;text-decoration:none;border-radius:6px">Bayar Sekarang</a>
          <a href="mailto:{{email}}?subject=Konfirmasi%20Pembayaran%20Uang%20Kas" style="display:inline-block;margin-bottom:12px;padding:10px 16px;background:#06b6d4;color:#fff;text-decoration:none;border-radius:6px">Konfirmasi Pembayaran</a>
        </p>

        <!-- Embedded QR code (base64 data URI) -->
        <p style="text-align:center;margin-top:18px">
          <img src="{{qr_url}}" alt="QR Code for Payment" style="width:150px;height:150px;"/>
        </p>

        <hr style="border:none;border-top:1px solid #eef2ff;margin:18px 0">
        <p style="margin:0;color:#888;font-size:12px">Terima kasih,<br/>Bendahara Uang Kas</p>
      </td>
    </tr>
  </table>
</body>
</html>'),

-- Sample paid (thank-you) template
('paid', '<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Terima Kasih — Pembayaran Diterima</title>
</head>
<body style="font-family: Arial, Helvetica, sans-serif; background:#f4f6f8; margin:0; padding:0;">
  <table role="presentation" width="100%" style="max-width:600px;margin:24px auto;background:#ffffff;border-radius:8px;overflow:hidden;box-shadow:0 2px 6px rgba(0,0,0,0.08);">
    <tr>
      <td style="background:linear-gradient(90deg,#10b981,#059669);padding:18px 24px;color:#ffffff">
        <h1 style="margin:0;font-size:20px;letter-spacing:0.2px">Terima Kasih — Pembayaran Diterima</h1>
      </td>
    </tr>
    <tr>
      <td style="padding:20px 24px;color:#333333">
        <p style="margin:0 0 12px 0;font-size:15px">Halo <strong>{{name}}</strong>,</p>
        <p style="margin:0 0 18px 0;color:#555;line-height:1.4">Terima kasih telah melakukan pembayaran uang kas sebesar <strong>{{amount}}</strong>. Kami menghargai ketepatan Anda.</p>
        <p style="margin:0 0 18px 0;color:#333">Kami akan mengingatkan kembali pada tanggal 25 bulan depan jika masih ada tagihan.</p>
        
        
        <hr style="border:none;border-top:1px solid #eef2ff;margin:18px 0">
        <p style="margin:0;color:#888;font-size:12px">Salam,<br/>Bendahara Uang Kas</p>
      </td>
    </tr>
  </table>
</body>
</html>');