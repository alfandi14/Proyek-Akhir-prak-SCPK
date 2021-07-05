clc; clear; close all; warning off all;

%membaca data asli dari excel
data = xlsread('bungkanel.xlsx',1,'B15:M17');

%transpose terhadap data asli
data = data';

%mengubah matriks menjadi bentuk vektor
data = data(:);

%mencari nilai min dan maks dari data
min_data = min(data);
max_data = max(data);

%normalisasi data untuk mengubah range data
[m,n] = size(data);
data_norm = zeros(m,n);
for x = 1:m
    for y = 1:n
        data_norm(x,y) = (data(x,y)-min_data)/(max_data-min_data);
    end
end

%menyiapkan data uji normalisasi
tahun_latih = 2;    %thaun 2012-2013
tahun_uji = 2;      %tahun 2013-3014
jumlah_bulan = 12;
data_uji_norm = zeros(jumlah_bulan*tahun_uji-jumlah_bulan,jumlah_bulan);

%menyusun data uji normalisasi
for m = 1:jumlah_bulan*tahun_uji-jumlah_bulan
    for n = 1:jumlah_bulan
        data_uji_norm(m,n) = data_norm(m+n-1+(tahun_latih-1)*jumlah_bulan); %tahun 2013-2014
    end
end

%menyiapkan target uji normalisasi
target_uji_norm = zeros(jumlah_bulan*tahun_uji-jumlah_bulan,1);
for m = 1:jumlah_bulan*tahun_uji-jumlah_bulan
    target_uji_norm(m) = data_norm(jumlah_bulan+m+(tahun_latih-1)*jumlah_bulan);    %tahun 2014
end

%transpose terhadap data uji normalisasi dan target uji norm
data_uji_norm = data_uji_norm';
target_uji_norm = target_uji_norm';

%memanggil arsitektur jst hasil pelatihan
load jaringan

%membaca hasil dari pengujian
hasil_uji_norm = sim(jaringan,data_uji_norm);

%denormalisasi terhadap hasil uji norm
hasil_uji_asli = round(hasil_uji_norm*(max_data-min_data)+min_data);

%membaca target uji asli
target_uji_asli = data(jumlah_bulan+1+(tahun_latih-1)*jumlah_bulan:...
    jumlah_bulan*tahun_uji+(tahun_latih-1)*jumlah_bulan);

%menghitung  nilai error MSE
nilai_error = hasil_uji_norm-target_uji_norm;
error_MSE = (1/n)*sum(nilai_error.^2);

%menampilkan grafik hasil pengujian
figure
plot(hasil_uji_asli,'ko-','LineWidth',2)
hold on
plot(target_uji_asli,'go-','LineWidth',2)
grid on
title(['Grafik Keluaran JST vs Target dengan nilai MSE = ', num2str(error_MSE)])
xlabel('Tahun 2014')
ylabel('Curah HUjan (mm/hari)')
legend('Keluaran JST', 'Target')
hold off

%menyiapkan data prdiksi normalisasi
data_prediksi_norm = hasil_uji_norm(end-11:end);
%transpose terhadap daata prediksi normalisasi
data_prediksi_norm = data_prediksi_norm';

%melalukan prediksi
hasil_prediksi_norm = sim(jaringan,data_prediksi_norm); %Januari 2015

for n = 1:11
    data_prediksi_norm = [data_prediksi_norm(end-10:end);hasil_prediksi_norm(end)];
    hasil_prediksi_norm = [hasil_prediksi_norm,sim(jaringan,data_prediksi_norm)];
end

%denormalisasi terhadap hasil prediksi
hasil_prediksi_asli = round(hasil_prediksi_norm*(max_data-min_data)+min_data); %hasil prediksi tahun 2015

%menampilkan grafik hasil prediksi
figure
plot(hasil_prediksi_asli,'mo-','LineWidth',2)
grid on
title('Grafik Keluaran JST')
xlabel('Tahun 2015')
ylabel('Curah Hujan (mm/hari)')
legend('Keluaran JST')

    
        
