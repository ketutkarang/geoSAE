# geoSAE
Repositori ini digunakan sebagai dokumentasi atau arsip untuk tugas akhir (skripsi) STIS, yaitu pengembangan metode geoadditive small area model pada software R

# Deskripsi File
1) Folder literatur
Pada folder ini berisikan file literatur atau referensi yang digunakan untuk rujukan penelitian ini

2) Folder package
Folder ini merupakan hasil akhir dalam penelitian ini, yaitu berupa pembangunan package geoSAE. Dalam package geoSAE terdiri dari
- File DESCRIPTION
Merupakan informasi umum tentang package yang dibangun. Informasi yang tercakup di dalamnya antara lain: judul package, nama penulis dan pengembang, versi, deskripsi, lisensi, dependensi package yang digunakan, dan beberapa informasi lainnya.
- File NAMESPACE 
File ini dibuat secara otomatis menggunakan package roxygen2. NAMESPACE menggambarkan interaksi package yang dibuat dengan package lain dan pengguna. 
File ini memastikan bahwa package yang dibangun dan package lain tidak saling mengganggu. Interaksi dengan package lain digambarkan pada item ‘import’, sedangkan interaksi dengan pengguna digambarkan pada item ‘export' yang berisi beberapa function yang dapat diakses oleh pengguna. 
- Folder R 
Berisi dokumentasi script R untuk menyusun package, dapat berupa function, ataupun dataset. 
- Folder man 
File ini di generate secara otomatis dari komentar berformat khusus pada script R. File ini berisi dokumentasi objek dalam package dalam format.Rd.
-Folder data 
Merupakan file yang berisikan data yang tersedia pada package. Data yang tersedia dalam package ini merupakan data yang berhubungan dengan metode yang digunakan.

3) Folder skrispi
Folder ini berisi file buku skripsi
