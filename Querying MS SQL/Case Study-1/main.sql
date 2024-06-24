-- SQL Alıştırmaları FLO

-- Soru 1: Customers isimli bir veritabanı ve verilen veri setindeki değişkenleri içerecek FLO isimli bir tablo oluşturunuz.
CREATE DATABASE CUSTOMERS

-- Soru 2: Kaç farklı müşterinin alışveriş yaptığını gösterecek sorguyu yazınız.
SELECT COUNT(DISTINCT(master_id)) AS DISTINCT_KISI_SAYISI FROM flo

-- Soru 3: Toplam yapılan alışveriş sayısı ve ciroyu getirecek sorguyu yazınız.
SELECT
    SUM(order_num_total_ever_online + order_num_total_ever_offline) AS TOPLAM_SİPARİS_SAYİSİ,
	ROUND(SUM(customer_value_total_ever_offline + customer_value_total_ever_online), 2) AS TOPLAM_CIRO
 FROM FLO

-- Soru 4: Alışveriş başına ortalama ciroyu getirecek sorguyu yazınız.
SELECT
ROUND((SUM(customer_value_total_ever_offline + customer_value_total_ever_online) / 
	SUM(order_num_total_ever_online+order_num_total_ever_offline) 
	), 2) AS SIPARIS_ORT_CIRO 
 FROM FLO
 
 -- Soru 5: En son alışveriş yapılan kanal (last_order_channel) üzerinden yapılan alışverişlerin toplam ciro ve alışveriş sayılarını getirecek sorguyu yazınız.
SELECT  last_order_channel SON_ALISVERIS_KANALI,
SUM(customer_value_total_ever_offline + customer_value_total_ever_online) AS TOPLAMCIRO,
SUM(order_num_total_ever_online+order_num_total_ever_offline) AS TOPLAM_SIPARIS_SAYISI
FROM FLO
GROUP BY last_order_channel

-- Soru 6: Store type kırılımında elde edilen toplam ciroyu getiren sorguyu yazınız.
SELECT store_type AS MAGAZA_TURU,
ROUND(SUM(customer_value_total_ever_offline + customer_value_total_ever_online), 2) AS TOPLAM_CIRO 
FROM FLO 
GROUP BY store_type

-- Soru 7: Yıl kırılımında alışveriş sayılarını getirecek sorguyu yazınız (Yıl olarak müşterinin ilk alışveriş tarihi (first_order_date) yılını baz alınız)
SELECT 
YEAR(first_order_date) YIL,  SUM(order_num_total_ever_offline + order_num_total_ever_online) SIPARIS_SAYISI
FROM  FLO
GROUP BY YEAR(first_order_date)

-- Soru 8: En son alışveriş yapılan kanal kırılımında alışveriş başına ortalama ciroyu hesaplayacak sorguyu yazınız.
SELECT last_order_channel, 
       ROUND(SUM(customer_value_total_ever_offline + customer_value_total_ever_online),2) TOPLAM_CIRO,
	   SUM(order_num_total_ever_offline + order_num_total_ever_online) TOPLAM_SIPARIS_SAYISI,
       ROUND(SUM(customer_value_total_ever_offline + customer_value_total_ever_online) / SUM(order_num_total_ever_offline + order_num_total_ever_online),2) AS VERIMLILIK
FROM FLO
GROUP BY last_order_channel;

-- Soru 9: Son 12 ayda en çok ilgi gören kategoriyi getiren sorguyu yazınız.alter
SELECT interested_in_categories_12, 
       COUNT(*) FREKANS_BILGISI 
FROM FLO
GROUP BY interested_in_categories_12
ORDER BY 2 DESC;

-- Soru 10:  En çok tercih edilen store_type bilgisini getiren sorguyu yazınız.
SELECT 
    store_type, 
    COUNT(*) AS FREKANS_BILGISI 
FROM FLO 
GROUP BY store_type 
ORDER BY COUNT(*) DESC 
LIMIT 1;

-- Soru 11: En son alışveriş yapılan kanal (last_order_channel) bazında, en çok ilgi gören kategoriyi ve bu kategoriden ne kadarlık alışveriş yapıldığını getiren sorguyu yazınız.
SELECT DISTINCT last_order_channel,
(
	SELECT interested_in_categories_12
	FROM FLO  WHERE last_order_channel=f.last_order_channel
	group by interested_in_categories_12
	order by 
	SUM(order_num_total_ever_online+order_num_total_ever_offline) desc LIMIT 1 
) AS KATEGORI,
(
	SELECT SUM(order_num_total_ever_online+order_num_total_ever_offline)
	FROM FLO  WHERE last_order_channel=f.last_order_channel
	group by interested_in_categories_12
	order by 
	SUM(order_num_total_ever_online+order_num_total_ever_offline) desc LIMIT 1
) AS ALISVERIS_SAYISI
FROM FLO F;

-- Soru 12: En çok alışveriş yapan kişinin ID’ sini getiren sorguyu yazınız.
SELECT D.master_id
FROM 
	(SELECT master_id, 
		   ROW_NUMBER() OVER(ORDER BY SUM(customer_value_total_ever_offline + customer_value_total_ever_online) DESC) RN
	FROM FLO 
	GROUP BY master_id) AS D
WHERE RN = 1;

-- Soru 13: En çok alışveriş yapan kişinin alışveriş başına ortalama cirosunu ve alışveriş yapma gün ortalamasını (alışveriş sıklığını) getiren sorguyu yazınız.
SELECT *,
ROUND((D.TOPLAM_CIRO / D.TOPLAM_SIPARIS_SAYISI),2) SIPARIS_BASINA_ORTALAMA
FROM
(
SELECT master_id,
		   SUM(customer_value_total_ever_offline + customer_value_total_ever_online) TOPLAM_CIRO,
		   SUM(order_num_total_ever_offline + order_num_total_ever_online) TOPLAM_SIPARIS_SAYISI
	FROM FLO 
	GROUP BY master_id
ORDER BY TOPLAM_CIRO DESC LIMIT 1
) D;

-- Soru 14: En çok alışveriş yapan (ciro bazında) ilk 100 kişinin alışveriş yapma gün ortalamasını (alışveriş sıklığını) getiren sorguyu yazınız. 
SELECT  
    D.master_id,
    D.TOPLAM_CIRO,
    D.TOPLAM_SIPARIS_SAYISI,
    ROUND((D.TOPLAM_CIRO / D.TOPLAM_SIPARIS_SAYISI), 2) AS SIPARIS_BASINA_ORTALAMA,
    DATEDIFF(D.last_order_date, D.first_order_date) AS ILK_SN_ALVRS_GUN_FRK,
    ROUND((DATEDIFF(D.last_order_date, D.first_order_date) / D.TOPLAM_SIPARIS_SAYISI), 1) AS ALISVERIS_GUN_ORT 
FROM
(
    SELECT 
        master_id, 
        first_order_date, 
        last_order_date,
        SUM(customer_value_total_ever_offline + customer_value_total_ever_online) AS TOPLAM_CIRO,
        SUM(order_num_total_ever_offline + order_num_total_ever_online) AS TOPLAM_SIPARIS_SAYISI
    FROM FLO 
    GROUP BY master_id, first_order_date, last_order_date
    ORDER BY TOPLAM_CIRO DESC 
    LIMIT 100
) D;

-- Soru 15: En son alışveriş yapılan kanal (last_order_channel) kırılımında en çok alışveriş yapan müşteriyi getiren sorguyu yazınız. 
SELECT DISTINCT last_order_channel,
(
	SELECT master_id
	FROM FLO  WHERE last_order_channel=f.last_order_channel
	group by master_id
	order by 
	SUM(customer_value_total_ever_offline+customer_value_total_ever_online) desc LIMIT 1 
) EN_COK_ALISVERIS_YAPAN_MUSTERI,
(
	SELECT SUM(customer_value_total_ever_offline+customer_value_total_ever_online)
	FROM FLO  WHERE last_order_channel=f.last_order_channel
	group by master_id
	order by 
	SUM(customer_value_total_ever_offline+customer_value_total_ever_online) desc LIMIT 1
) CIRO
FROM FLO F;

-- Soru 16: En son alışveriş yapan kişinin ID’ sini getiren sorguyu yazınız. (Max son tarihte birden fazla alışveriş yapan ID bulunmakta. Bunları da getiriniz.)
SELECT master_id,last_order_date 
FROM FLO
WHERE last_order_date=(SELECT MAX(last_order_date) FROM FLO)