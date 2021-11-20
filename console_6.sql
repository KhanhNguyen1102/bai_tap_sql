use demo20062;
# 6. In ra các số hóa đơn, trị giá hóa đơn bán ra trong ngày 19/6/2006 và ngày 20/6/2006.
# select `order`.id ,sum(orderdetail.quantity*product.price) as total,time
# from `order`join orderdetail on `order`.id = orderdetail.orderId join product on product.id = orderdetail.productId
# where time = '2006-06-19' or time = '2006-06-20'
# group by `order`.id;
# 7. In ra các số hóa đơn, trị giá hóa đơn trong tháng 6/2007, sắp xếp theo ngày (tăng dần) và trị giá của hóa đơn (giảm dần).
# select `order`.id,sum(orderdetail.quantity*product.price) as total,time
# from `order`join orderdetail on `order`.id = orderdetail.orderId join product on product.id = orderdetail.productId
# where MONTH(time) = 6 and YEAR(time) = 2007
# group by `order`.id,time
# order by time ,total desc;
# 8. In ra danh sách các khách hàng (MAKH, HOTEN) đã mua hàng trong ngày 19/06/2007.
# select customer.id,name
# from customer join `order` on customer.id = `order`.customerId
# where time = '2007-06-19'
# group by customer.id
# 10. In ra danh sách các sản phẩm (MASP,TENSP) được khách hàng có tên “Nguyen Van A” mua trong tháng 10/2006.
# select product.id,product.name
# from customer join `order` on customer.id = `order`.customerId join orderdetail on `order`.id = orderdetail.orderId join product on orderdetail.productId = product.id
# where customer.name = 'Nguyen Van A' and MONTH(time) = 10 and YEAR(time) = 2006
# group by product.id;
# 11. Tìm các số hóa đơn đã mua sản phẩm “Máy giặt” hoặc “Tủ lạnh”.
# select `order`.id,product.name
# from `order` join orderdetail on `order`.id = orderdetail.orderId join product on orderdetail.productId = product.id
# where product.name = 'máy giặt' or product.name = 'Tủ lạnh'
# group by `order`.id
# 12. Tìm các số hóa đơn đã mua sản phẩm “Máy giặt” hoặc “Tủ lạnh”, mỗi sản phẩm mua với số lượng từ 10 đến 20.
# select `order`.id,product.name,orderdetail.quantity
# from `order` join orderdetail on `order`.id = orderdetail.orderId join product on orderdetail.productId = product.id
# where (product.name = 'máy giặt' or product.name = 'Tủ lạnh') and (orderdetail.quantity between 10 and 20)
# 13. Tìm các số hóa đơn mua cùng lúc 2 sản phẩm “Máy giặt” và “Tủ lạnh”, mỗi sản phẩm mua với số lượng từ 10 đến 20.
# có thể dùng view hoặc intersect chèn giữa 2 select
# create view case13_1 as
# select `order`.id,product.name,orderdetail.quantity
# from `order` join orderdetail on `order`.id = orderdetail.orderId join product on orderdetail.productId = product.id
# where (product.name = 'máy giặt') and (orderdetail.quantity between 10 and 20);
# create view case13_2 as
# select `order`.id,product.name,orderdetail.quantity
# from `order` join orderdetail on `order`.id = orderdetail.orderId join product on orderdetail.productId = product.id
# where (product.name = 'Tủ lạnh') and (orderdetail.quantity between 10 and 20);
# select case13_1.id
# from case13_1 join case13_2 on case13_1.id=case13_2.id
# 15. In ra danh sách các sản phẩm (MASP,TENSP) không bán được.
# select product.id,product.name
# # from product
# # where product.id not in (select productId from orderdetail)
# # group by product.id
# 16. In ra danh sách các sản phẩm (MASP,TENSP) không bán được trong năm 2006.
# create view case16 as
# select product.id,product.name
# from product join orderdetail on product.id = orderdetail.productId join `order` on orderdetail.orderId = `order`.id
# where YEAR(time) = 2006
# group by product.id;
# select product.id,product.name
# from product
# where product.id not in (select case16.id from case16)
# 17. In ra danh sách các sản phẩm (MASP,TENSP) có giá >300 sản xuất bán được trong năm 2006.
# select product.id ,product.name,product.price
# from product
# where product.id in (select case16.id from case16) and price>300
# group by product.id;
# 18. Tìm số hóa đơn đã mua tất cả các sản phẩm có giá >200.
# create view case18 as
#     select product.id,product.name
#     from product
#     where price >200
#     group by product.id;
# select `order`.id,count(productId) as `product>200`
# from `order` join orderdetail on `order`.id = orderdetail.orderId
# where productId in (select case18.id from case18)
# group by `order`.id
# having `product>200` >= (select count(id) from case18)

# 19. Tìm số hóa đơn trong năm 2006 đã mua tất cả các sản phẩm có giá <300.
# create view case19 as
#     select product.id,product.name
#     from product
#     where price < 300
#     group by product.id;
# select `order`.id,count(productId) as `product<300`
# from `order` join orderdetail on `order`.id = orderdetail.orderId
# where (productId in (select case19.id from case19)) and (YEAR(time) = 2006)
# group by `order`.id
# having `product<300` >= (select count(id) from case19)
# 21. Có bao nhiêu sản phẩm khác nhau được bán ra trong năm 2006.
# select count(productId) as result
# from (
#          select productId
#          from orderdetail
#                   join `order` on orderdetail.orderId = `order`.id
#          where YEAR(time) = 2006
#          group by productId) as sobilltrong2006
# 22. Cho biết trị giá hóa đơn cao nhất, thấp nhất là bao nhiêu?
# create view case22 as
# select `order`.id, sum(orderdetail.quantity * product.price) as total
# from `order`
#          join orderdetail on `order`.id = orderdetail.orderId
#          join product on orderdetail.productId = product.id
# group by `order`.id;
# select id ,total
# from case22
# where total >= (select MAX(total) from case22)
# union all
# select id ,total
# from case22
# where total <= (select MIN(total) from case22)
# 23. Trị giá trung bình của tất cả các hóa đơn được bán ra trong năm 2006 là bao nhiêu?
# select AVG(total) as AVGBILL from (
# select `order`.id, sum(orderdetail.quantity * product.price) as total
# from `order`
#          join orderdetail on `order`.id = orderdetail.orderId
#          join product on orderdetail.productId = product.id
# where YEAR(time) = 2006
# group by `order`.id)as calBill;
# 24. Tính doanh thu bán hàng trong năm 2006.
# select sum(total) as tongdoanhthu
# from (select `order`.id, sum(orderdetail.quantity * product.price) as total
#       from `order`
#                join orderdetail on `order`.id = orderdetail.orderId
#                join product on orderdetail.productId = product.id
#       where YEAR(time) = 2006
#       group by `order`.id) as calBill
# ;
# 25 Tìm số hóa đơn có trị giá cao nhất trong năm 2006.
# create view case25 as
# select `order`.id, sum(orderdetail.quantity * product.price) as total
# from `order`
#          join orderdetail on `order`.id = orderdetail.orderId
#          join product on orderdetail.productId = product.id
# where YEAR(time) = 2006
# group by `order`.id;
# select id,MAX(total) as maxValueBill
# from case25
# where total>=(select MAX(total) from case25)
# 26. Tìm họ tên khách hàng đã mua hóa đơn có trị giá cao nhất trong năm 2006.
# select *
# from (select customer.name, case25.id as idBill, case25.total
#       from customer
#                join `order` on customer.id = `order`.customerId
#                join case25 on `order`.id = case25.id) as calBillAndNameCus
# where total >= (select MAX(total) from case25)
# 27. In ra danh sách 3 khách hàng (MAKH, HOTEN) mua nhiều hàng nhất (tính theo số lượng).
# select customer.id,customer.name,sum(orderdetail.quantity) as totalQuantity
# from customer join `order` on customer.id = `order`.customerId
# join orderdetail on `order`.id = orderdetail.orderId
# group by customer.id, customer.name
# order by totalQuantity desc
# limit 3;
# 28. In ra danh sách các sản phẩm (MASP, TENSP) có giá bán bằng 1 trong 3 mức giá cao nhất.
# create view case28 as
# select price
# from product
# group by price
# order by price desc
# limit 3
# select product.id,product.name
# from product
# where price in (select price from case28)
# 29. In ra danh sách các sản phẩm (MASP, TENSP) có tên bắt đầu bằng chữ M, có giá bằng 1 trong 3 mức giá cao nhất (của tất cả các sản phẩm).
# select product.id,product.name
# from product
# where price in (select price from case28) and product.name like 'M%'
# 32. Tính tổng số sản phẩm giá <300.
# select SUM(quantity) as `soLuongSanPhamGiaNhoHon300`
# from (select product.id,price,quantity from product where price<300) as `list<300`
# 33. Tính tổng số sản phẩm theo từng giá.
# select price,sum(quantity)
# from product
# group by price
# 34. Tìm giá bán cao nhất, thấp nhất, trung bình của các sản phẩm bắt đầu bằng chữ M.
# create view case34 as
# select product.id, product.name,product.price
# from product
# where name like 'M%'
# group by product.id
# select MAX(price) as Max_AVG_Min_price
# from case34
# union
# select AVG(price)
# from case34
# union
# select MIN(price)
# from case34
#35. Tính doanh thu bán hàng mỗi ngày
# select time,sum(price*orderdetail.quantity) as Doanh_thu
# from `order` join orderdetail on `order`.id = orderdetail.orderId join product on orderdetail.productId = product.id
# group by time
# order by time
# 36. Tính tổng số lượng của từng sản phẩm bán ra trong tháng 10/2006.
# select product.id,SUM(orderdetail.quantity) as so_luong_ban
# from product join orderdetail on product.id = orderdetail.productId join `order` on orderdetail.orderId = `order`.id
# where YEAR(time) = 2006 and MONTH(time) = 10
# group by product.id
# 37. Tính doanh thu bán hàng của từng tháng trong năm 2006.
# select MONTH(time)as month,sum(price*orderdetail.quantity) as Doanh_thu
# from `order` join orderdetail on `order`.id = orderdetail.orderId join product on orderdetail.productId = product.id
# where YEAR(time) =2006
# group by month
# 38. Tìm hóa đơn có mua ít nhất 4 sản phẩm khác nhau
# select orderId,count(productId)as so_san_pham_khac_nhau
# from orderdetail
# group by orderId
# having so_san_pham_khac_nhau >=4
# 39. Tìm hóa đơn có mua 3 sản phẩm có giá <300 (3 sản phẩm khác nhau).
# select orderId,count(productId)as so_san_pham_khac_nhau
# from orderdetail
# where productId in (select id from case19)
# group by orderId
# having so_san_pham_khac_nhau =3
# 40. Tìm khách hàng (MAKH, HOTEN) có số lần mua hàng nhiều nhất.
# create view case40 as
# select customerId,count(`order`.id) as so_lan_mua_hang
# from `order`
# group by customerId;
# select customer.id,customer.name,so_lan_mua_hang
# from customer join case40 on customer.id = case40.customerId
# where so_lan_mua_hang >= (select MAX(so_lan_mua_hang) from case40)
# 41. Tháng mấy trong năm 2006, doanh số bán hàng cao nhất?
# create view case41 as
# select MONTH(time)as thang,sum(price*orderdetail.quantity) as Doanh_thu
# from `order` join orderdetail on `order`.id = orderdetail.orderId join product on orderdetail.productId = product.id
# where YEAR(time) =2006
# group by month
# select month as thang ,Doanh_thu
# from case41
# where Doanh_thu >= (select MAX(Doanh_thu) from case41)
# 42. Tìm sản phẩm (MASP, TENSP) có tổng số lượng bán ra thấp nhất trong năm 2006.
# trường hợp 1: chỉ tính bọn có số bán
# create view case42 as
# select product.id,product.name,SUM(orderdetail.quantity) as so_luong_ban
# from product  join orderdetail on product.id = orderdetail.productId  join `order` on orderdetail.orderId = `order`.id
# where YEAR(time) = 2006
# group by product.id;
# select id,name,so_luong_ban
# from case42
# where so_luong_ban<=(select MIN(so_luong_ban) from case42)
# group by id;
# trường hợp 2: tính cả bọn ko bán được tí nào
# create or replace view case42_1 as
# select product.id,product.name,SUM(orderdetail.quantity) as total
# from product join orderdetail on product.id = orderdetail.productId join `order` on orderdetail.orderId = `order`.id
# where YEAR(time) =2006
# group by product.id;
# create or replace view case42_2 as
# select product.id,product.name,case42_1.total
# from product left join case42_1 on product.id= case42_1.id
# group by product.id;
# select id,name,total
# from case42_2
# where total<=(select MIN(case42_1.total) from case42_1)or case42_2.total is null
# group by id
# 45. Trong 10 khách hàng có doanh số cao nhất, tìm khách hàng có số lần mua hàng nhiều nhất.
# Bảng top 10
# create view case45 as
# select customer.id,customer.name,sum(product.price*orderdetail.quantity) as total
# from customer join `order` on customer.id = `order`.customerId join orderdetail on `order`.id = orderdetail.orderId join product on orderdetail.productId = product.id
# group by customer.id
# order by total desc
# limit 10;
# # bảng top số lần mua hàng
# create view case45_1 as
# select customerId,count(`order`.id)as buytimes
# from `order`
# group by customerId
# order by buytimes desc;
# ko dùng view
# select id
# from (select customer.id,customer.name,sum(product.price*orderdetail.quantity) as total
#       from customer join `order` on customer.id = `order`.customerId join orderdetail on `order`.id = orderdetail.orderId join product on orderdetail.productId = product.id
#       group by customer.id
#       order by total desc
#       limit 10) as top10 join (select customerId,count(`order`.id)as buytimes
#                       from `order`
#                       group by customerId
#                       order by buytimes desc) as topbuytimes on top10.id = topbuytimes.customerId
# where buytimes >= (select MAX(buytimes) from (select count(`order`.id)as buytimes
#                                               from `order`
#                                               group by customerId
#                                               order by buytimes desc)as topbuytimes1)





