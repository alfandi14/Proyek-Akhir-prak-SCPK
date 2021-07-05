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

%menyiapkan data latih normalisasi
tahun_latih = 2;    %thn 2012 - 2013
jumlah_bulan = 12;
data_latih_norm = zeros(jumlah_bulan*tahun_latih-jumlah_bulan, jumlah_bulan);

%menyusun data latih normalisasi
for m = 1:jumlah_bulan*tahun_latih-jumlah_bulan
    for n = 1:jumlah_bulan
        data_latih_norm(m,n) = data_norm(m+n-1);
    end
end

%menyiapkan target latihan normalisasi
target_latih_norm = zeros(jumlah_bulan*tahun_latih-jumlah_bulan,1);
for m = 1:jumlah_bulan*tahun_latih-jumlah_bulan
    target_latih_norm(m) = data_norm(jumlah_bulan+m);  %target pola tahun 2013
end

%transpose terhadap data latih norm dan target latih norm
data_latih_norm = data_latih_norm';
target_latih_norm = target_latih_norm';

%menetapkan parameter jst
jumlah_neuron1 = 100;
fungsi_aktivasi1 = 'logsig';
fungsi_aktivasi2 = 'logsig';
fungsi_pelatihan = 'trainlm';

%membangun arsitektur jst beckpropagation
rng('default');
jaringan = newff(minmax(data_latih_norm),[jumlah_neuron1 1],...
    {fungsi_aktivasi1,fungsi_aktivasi2},fungsi_pelatihan);

%melakukan pelatihan jaringan
jaringan = train(jaringan,data_latih_norm, target_latih_norm);

%membaca hasil pelatihan
hasil_latih_norm = sim(jaringan, data_latih_norm);

%melakukan denormalisasi terhadap hasil norm
hasil_latih_asli = round(hasil_latih_norm*(max_data-min_data)+min_data);

%membaca target latih asli
target_latih_asli = data(jumlah_bulan+1:jumlah_bulan*tahun_latih);  %tahun 2013

%menghitung nilai MSE
nilai_error = hasil_latih_norm-target_latih_norm;
error_MSE = (1/n)*sum(nilai_error.^2);

%menampilkan grafik hasil latihan
figure
plot(hasil_latih_asli, 'bo-','LineWidth',2)
hold on
plot(target_latih_asli, 'ro-','LineWidth',2)
grid on
title(['Grafik Keluaran JST vs Target dengan nilai MSE = ',num2str(error_MSE)])
xlabel('Tahun 2013')
ylabel('Curah hujan (mm/hari)')
legend('Keluaran JST', 'Target')
hold off

%menyimpan arsitektur JST hasil pelatihan
save jaringan jaringan