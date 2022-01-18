import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kiosq_app/Database/Preferences/lang_preferences.dart';

class Strings extends ChangeNotifier {
  late String _id;
  late LangPreferences _preferences;

  static Map<String, String> lang = {
    "id_ID": "Indonesia",
    "en_US": "English",
  };

  Strings() {
    _id = "id_ID";
    Intl.defaultLocale = _id;
    _preferences = LangPreferences();
    getPreferences();
  }
//Switching themes in the flutter apps - Flutterant
  set id(String value) {
    _preferences.setLang(value);
    _id = value;
    Intl.defaultLocale = _id;
    notifyListeners();
  }

  String get id => _id;

  int get id_ {
    return lang.keys.toList().indexOf(_id);
  }

  getPreferences() async {
    _id = await _preferences.getLang();
    notifyListeners();
  }

  String get settings => ["Pengaturan", "Settings"][id_];
  String get basics => ["Konfigurasi Umum", "Basic Configuration"][id_];
  String get languages => ["Bahasa", "Languages"][id_];
  String get profile => ["Profil", "Profile"][id_];
  String get firstname => ["Nama depan", "First name"][id_];
  String get lastname => ["Nama belakang", "Last name"][id_];
  String get address => ["Alamat", "Address"][id_];
  String get professional => ["Profesional", "Professional"][id_];
  String get asktochangemyrole =>
      ["Ajukan diri untuk mengganti peran", "Ask to change my role"][id_];
  String get uploadselfie => ["Foto selfie", "Selfie photo"][id_];
  String get uploadcertificate => ["Sertifikat", "Certificate"][id_];
  String get uploadidentitycard => ["Kartu identitas", "Identity card"][id_];
  String get uploadcv => ["CV", "CV"][id_];
  String get disabled => ["Dimatikan", "Disabled"][id_];
  String get enabled => ["Dinyalakan", "Enabled"][id_];
  String get aboutMe => ["Tentang saya", "About me"][id_];
  String get portodescription =>
      ["Deskripsikan portofolio anda", "Describe your portofolio"][id_];
  String get profiledescription =>
      ["Deskripsikan profil anda", "Describe your profile"][id_];
  String get administrator => ["Administrator", "Administrator"][id_];
  String get askdentistdetail => [
        "Ajukan diri saya pada superuser untuk mendapatkan peran sebagai Doktor Gigi",
        "Ask the superuser team to assign my profile as Dentist"
      ][id_];
  String get askadmindetail => [
        "Ajukan diri saya pada superuser untuk mendapatkan peran sebagai Admin",
        "Ask the superuser team to assign my profile as Admin"
      ][id_];
  String get asksuperuserdetail => [
        "Ajukan diri saya pada superuser untuk mendapatkan peran sebagai Superuser",
        "Ask the superuser team to assign my profile as Superuser"
      ][id_];
  String get documentAttachments =>
      ["Lampiran dokumen", "Document Attachments"][id_];
  String get documentAttachmentsDetail => [
        "Lampiran berkas pendukung agar proses verifikasi lebih cepat dan terpercaya",
        "Attach your supportive document for faster and more reliable verification process"
      ][id_];
  String get aboutMeDetail =>
      ["Edit deskripsi tentang saya", "Edit the description about me"][id_];
  String get addYourPortoHere =>
      ["Tambahkan portofolio anda disini", "Add your portofolio(s) here"][id_];
  String get addYourProfileHere => [
        "Tambahkan informasi profil anda disini",
        "Add your profile information here"
      ][id_];
  String get chats => ["Pesan", "Chats"][id_];
  String get dentalProducts => ["Produk", "Products"][id_];
  String get popularProducts => ["Produk terlaris", "Popular Products"][id_];
  String get myKiosks => ["Kiosku", "My Kiosks"][id_];
  String get nearbyKiosks => ["Kios terdekat", "Nearby Kiosks"][id_];
  String get help => ["Bantuan", "Help"][id_];
  String get about => ["Tentang", "About"][id_];
  String get logout => ["Keluar", "Logout"][id_];
  String get createANewKiosk => ["Buat kios baru", "Create a new kiosk"][id_];
  String get addvideo =>
      ["Tambahkan video edukasi", "Add educational video"][id_];
  String get carts => ["Keranjang", "Charts"][id_];
  String get welcome => ["Selamat datang", "Welcome"][id_];
  String get healthwishes => [
        "Temukan jajanan favoritmu, penuhi kebutuhanmu",
        "Explore nearby food, fulfil your hungry-ness"
      ][id_];
  String get signnow => [
        "Login sekarang untuk mendapatkan fitur selengkapnya",
        "Sign in now to get more features"
      ][id_];
  String get signinwithgoogle =>
      ["Masuk dengan Google", "Login with Goole"][id_];
  String get guest => ["Tamu", "Guest"][id_];
  String get user => ["Pengguna", "User"][id_];
  String get movingKiosks => ["Jajanan keliling", "Moving kiosks"][id_];
  String get videoplayer => ["Pemutar video", "Video player"][id_];
  String get findNearbyKiosk =>
      ["Temukan kios terdekat", "Find nearby kiosk"][id_];
  String get openchatwithpatient =>
      ["Buka obrolan dengan pasien", "Open a chat with the patient"][id_];
  String get visitus => ["Kunjungi kios-q.web.app", "Visit kiosq_app.id"][id_];
  String get dashboard => ["Dasbor", "Dashboard"][id_];
  String get hello => ["Halo", "Hello"][id_];
  String get search => ["Cari", "Search"][id_];
  String get error => ["Kesalahan", "Error"][id_];
  String get sent => ["Terkirim", "Sent"][id_];
  String get delivered => ["Sampai", "Delivered"][id_];
  String get seen => ["Baca", "Seen"][id_];
  String get sending => ["Mengirim", "Sending"][id_];
  String get more => ["Selengkapnya", "More"][id_];
  String get empty => ["Kosong", "Empty"][id_];
  String get alphabet => ["Alfabet", "Alphabet"][id_];
  String get date => ["Tanggal dibuat", "Date upload"][id_];
  String get asc => ["Naik", "Ascending"][id_];
  String get desc => ["Turun", "Descending"][id_];
  String get sort => ["Urutkan", "Sort"][id_];
  String get admin => ["Admin", "Admin"][id_];
  String get dentist => ["Dokter Gigi", "Dentist"][id_];
  String get superuser => ["Superuser", "Superuser"][id_];
  String get failedLogout => ["Gagal Keluar", "Logout Failed"][id_];
  String get successLogout => ["Berhasil Keluar", "Logout Success"][id_];
  String get successLogin => ["Berhasil Masuk", "Login Success"][id_];
  String get failedLogin => ["Gagal Masuk", "Login Failed"][id_];
  String get failedUpdate => ["Gagal Memperbarui", "Update Failed"][id_];
  String get successUpdate => ["Berhasil Memperbarui", "Update Success"][id_];
  String get lastSeen => ["Terakhir terlihat", "Last seen"][id_];
  String get ago => ["yang lalu", "ago"][id_];
  String get minutes => ["menit", "minutes"][id_];
  String get hours => ["jam", "hours"][id_];
  String get days => ["hari", "days"][id_];
  String get months => ["bulan", "months"][id_];
  String get years => ["tahun", "years"][id_];
  String get theme => ["Mode tema", "Theme mode"][id_];
  String get system => ["Sistem", "System"][id_];
  String get light => ["Terang", "Light"][id_];
  String get dark => ["Gelap", "Dark"][id_];
  String get loading => ["Memuat", "Loading"][id_];
  String get downloading => ["Mengunduh", "Downloading"][id_];
  String get uploading => ["Mengunggah", "Uploading"][id_];
  String get uploadComplete =>
      ["Berhasil mengunggah", "Upload successful"][id_];
  String get cancel => ["Batal", "Cancel"][id_];
  String get uploadFailed => ["Gagal mengunggah", "Upload failed"][id_];
  String get changeRole => ["Ubah peran", "Change role"][id_];
  String get requested => ["Diminta", "Requested"][id_];
  String get of => ["dari", "of"][id_];
  String get porto => ["Portofolio", "Portofolio"][id_];
  String get size => ["Ukuran", "Size"][id_];
  String get comingSoon => ["Segera hadir", "Coming soon"][id_];
  String get createaproduct => ["Buat produk", "Create product"][id_];
  String get addtitle => ["Tambahkan nama kios", "Add kiosk name"][id_];
  String get adddescription => ["Tambahkan deskripsi", "Add description"][id_];
  String get addproductsname =>
      ["Tambahkan nama produk", "Add product's name"][id_];
  String get addthumbnail => ["Tambahkan gambar sampul", "Add thumbnail"][id_];
  String get addcontent => ["Tambahkan konten", "Add content"][id_];
  String get uploader => ["Unggahan", "Uploader"][id_];
  String get thumbnail => ["Gambar sampul", "Thumbnail"][id_];
  String get content => ["Konten", "Content"][id_];
  String get latest => ["Terbaru", "Latest"][id_];
  String get addNews => ["Tambahkan Berita", "Add News"][id_];
  String get attachurl => ["Sematkan url link", "Attach url's link"][id_];
  String get urllinknotvalid =>
      ["Link url tidak benar", "Url's link is not valid"][id_];
  String get cannotDeleteObject =>
      ["Tidak dapat menghapus objek", "Cannot delete object"][id_];
  String get cannotAddObject =>
      ["Tidak dapat menambahkan objek", "Cannot add object"][id_];
  String get description => ["Deskripsi", "Description"][id_];
  String get cannotFindDoctor =>
      ["Tidak dapat menemukan obrolan", "Cannot find any chats"][id_];
  String get letsStartTheConversation =>
      ["Mari mulai mengobrol!", "Let's start the conversation!"][id_];
  String get deleting => ["Menghapus", "Deleting"][id_];
  String get areYouSure => [
        "Apa kamu yakin?\nMenghapus seluruh pesan akan menghapus juga kontak dokter dari daftar\nAbaikan untuk membatalkan",
        "Are you sure?\nDeleting the entire message will also remove the doctor's contact from the list\nIgnore to cancel"
      ][id_];
  String get ok => ["Ya", "Yes"][id_];
  String get sendImage => ["Kirim gambar", "Send an image"][id_];
  String get photo => ["Foto", "Photo"][id_];
  String get anew => ["Baru", "New"][id_];
  String get newMessages => ["Pesan baru", "New messages"][id_];
  String get downloadPascaForAndroid =>
      ["Unduh untuk android", "Download for android"][id_];
  String get alertOnlyApp => [
        "Fitur ini hanya tersedia pada aplikasi",
        "This feature only available on app version"
      ][id_];
  String get alert => ["Peringatan", "Alert"][id_];
  String get lsad => [
        "Layanan lokasi tidak dinyalakan",
        'Location services are disabled'
      ][id_];
  String get lpad => [
        "Layanan lokasi tidak diizinkan",
        'Location permissions are denied'
      ][id_];
  String get lppd => [
        "Layanan lokasi tidak diizinkan secara permanen, kami tidak dapat meminta akses lokasi",
        'Location permissions are permanently denied, we cannot request permissions.'
      ][id_];
  String get pinLocation => ["Pin lokasi", "Location pin"][id_];
  String get distance => ["Jarak", "Distance"][id_];
  String get offline => ["Offline", "Offline"][id_];
  String get price => ["Harga", "Price"][id_];
  String get sold => ["Terjual", "Sold"][id_];
  String get addproduct => ["Nama produk", "Product's name"][id_];
  String get addean => ["EAN (barcode)", "EAN (barcode)"][id_];
  String get addprice => ["Harga", "price"][id_];
  String get addvendor => ["Vendor", "Vendor"][id_];
  String get addvariance => ["Varian", "Variance"][id_];
  String get addstock => ["Stok tersedia", "Available stocks"][id_];
  String get addpcspqty => ["buah/bungkus", "pcs/qty"][id_];
  String get sellingpcs => ["Jual perbuah", "Sell per pcs"][id_];
  String get grocery => ["Grosir per bungkus", "Grocery"][id_];
  String get sellingqty => ["Jual perbungkus", "Sell per qty"][id_];
  String get searchProduct => ["Cari produk di", "Search product at"][id_];
  String get recommended => ["direkomendasikan", "recommended"][id_];
  String get required => ["dibutuhkan", "required"][id_];
  String get optional => ["opsional", "optional"][id_];
  String get soldout => ["HABIS", "SOLD OYUT"][id_];
  String get successToFetchData =>
      ["Berhasil mendapatkan data", "Success to fetch data"][id_];
  String get selectRelevantOption =>
      ["Pilihlah opsi yang relevan", "Select a relevant option"][id_];
}
