use quanlyvantai;
# 1. Tạo cơ sở dữ liệu trên, với các khóa chính như sau:
# ChiTietVanTai là MaVT, TrongTai là MaTrongTai, LoTrinh là MaLoTrinh
# 2. Tạo view gồm các trường SoXe, MaLoTrinh, SoLuongVT, NgayDi, NgayDen,
# ThoiGianVT, CuocPhi, Thuong. Trong đó:
# • ThoiGianVT: là 1 nếu vận chuyển trong ngày, là (NgayDen-NgayDi) trong trường hợp
# ngược lại.
# • CuocPhi: là SoLuongVT x DonGia x 105% nếu SoLuongVT nhiều hơn TrongTaiQD, là
# SoLuongVT x DonGia trong trường hợp ngược lại.
# • Thuong: là 5% của CuocPhi nếu ThoiGianVT vuot ThoiGianQD, là 0 trong trường hợp
# ngược lại.
delimiter //
drop function if exists tinhThoiGianVT;
create function tinhThoiGianVT(ngaydi datetime, ngayden datetime) returns int deterministic
begin
    if (datediff(ngayden, ngaydi) = 0)
    then
        return 1;
    else
        return datediff(ngayden, ngaydi);
    end if;
end //
delimiter ;
delimiter //
drop function if exists tinhCuocPhi;
create function tinhCuocPhi(SoLuongVT int, MaTrongTai varchar(20), MaLoTrinh varchar(20)) returns double deterministic
begin

    if (SoLuongVT > (select TrongTaiQD
                     from trongtai
                     where trongtai.MaTrongTai = MaTrongTai))
    then
        return SoLuongVT * (select DonGia
                            from lotrinh
                            where lotrinh.MaLoTrinh = MaLoTrinh) * 1.05;
    else
        return SoLuongVT * (select DonGia
                            from lotrinh
                            where lotrinh.MaLoTrinh = MaLoTrinh);
    end if;
end //
delimiter ;
delimiter //
drop function if exists tinhThuong1;
create function tinhThuong1(ngaydi datetime, ngayden datetime, SoLuongVT int, MaTrongTai varchar(20),
                            MaLoTrinh varchar(20)) returns double deterministic
begin
    declare ThoiGianVT int;
    declare CuocPhi double;
    set ThoiGianVT = tinhThoiGianVT(NgayDi, NgayDen);
    set CuocPhi = tinhCuocPhi(SoLuongVT, MaTrongTai, MaLoTrinh);
    if (ThoiGianVT > (select ThoiGianQD
                      from lotrinh
                      where lotrinh.MaLoTrinh = MaLoTrinh))
    then
        return CuocPhi * 0.05;
    else
        return 0;
    end if;
end //
delimiter ;
create or replace view case2 as
select Soxe,
       MaLoTrinh,
       SoLuongVT,
       NgayDi,
       NgayDen,
       tinhThoiGianVT(NgayDi, NgayDen)                                as thoiGianVT,
       tinhCuocPhi(SoLuongVT, MaTrongTai, MaLoTrinh)                  as CuocPhi,
       tinhThuong1(NgayDi, NgayDen, SoLuongVT, MaTrongTai, MaLoTrinh) as Thuong
from chitietvantai
group by MaVT;
# 3. Tạo view để lập bảng cước phí gồm các trường SoXe, TenLoTrinh, SoLuongVT, NgayDi,
# NgayDen, CuocPhi.
create or replace view case3 as
select Soxe,
       TenLoTrinh,
       SoLuongVT,
       NgayDi,
       NgayDen,
       tinhCuocPhi(SoLuongVT, MaTrongTai, chitietvantai.MaLoTrinh) as CuocPhi
from chitietvantai
         join lotrinh on chitietvantai.MaLoTrinh = lotrinh.MaLoTrinh
group by MaVT;
# 4. Tạo view danh sách các xe có có SoLuongVT vượt trọng tải qui định, gồm các trường
# SoXe, TenLoTrinh, SoLuongVT, TronTaiQD, NgayDi, NgayDen.
create or replace view case4 as
select Soxe, TenLoTrinh, SoLuongVT, TrongTaiQD, NgayDi, NgayDen
from chitietvantai
         join lotrinh on chitietvantai.MaLoTrinh = lotrinh.MaLoTrinh
         join trongtai on chitietvantai.MaTrongTai = trongtai.MaTrongTai
where SoLuongVT > (select TrongTaiQD from trongtai where chitietvantai.MaTrongTai = trongtai.MaTrongTai);
# 5. Tạo thủ tục có đầu vào là lộ trình, đầu ra là số xe, mã trọng tải, số lượng vận tải, ngày đi, ngày
# đến (SoXe, MaTrongTai, SoLuongVT, NgayDi, NgayDen.)
delimiter //
drop procedure if exists KiemTraLoTrinh;
create procedure KiemTraLoTrinh(In MaLoTrinh varchar(20))
begin
    select Soxe, MaTrongTai, SoLuongVT, NgayDi, NgayDen
    from chitietvantai
    where chitietvantai.MaLoTrinh = MaLoTrinh
    group by MaVT;
end //
delimiter ;
call KiemTraLoTrinh(1);
# 6. Thiết lập procedure có đầu vào là số xe, đầu ra là thông tin về lộ trình
delimiter //
drop procedure if exists KiemTraLoTrinhBangSoXe;
create procedure KiemTraLoTrinhBangSoXe(In Soxe varchar(20))
begin
    select lotrinh.MaLoTrinh, TenLoTrinh, DonGia, ThoiGianQD
    from lotrinh
             join chitietvantai on lotrinh.MaLoTrinh = chitietvantai.MaLoTrinh
    where chitietvantai.Soxe = Soxe
    group by MaVT;
end //
delimiter ;
call KiemTraLoTrinhBangSoXe(1);
# 7. Thêm trường Thành tiền vào bảng chi tiết vận tải và tạo trigger điền dữ liệu cho trường này
# biết:
# Thành tiền = là SoLuongVT x DonGia x 105% nếu SoLuongVT nhiều hơn TrongTaiQD, là
# SoLuongVT x DonGia trong trường hợp ngược lại
# Chưa học triggerrrrrrr
# 8. Tạo thủ tục có đầu vào là mã lộ trình, năm vận tải, đầu ra là số tiền theo mã lộ trình đó
delimiter //
drop procedure if exists TinhTienTheoMaLoTrinhVaNam;
create procedure TinhTienTheoMaLoTrinhVaNam(In MaLoTrinh varchar(20), in NamVanTai int, out result double)
begin
    declare CuocPhi double;
    declare Thuong1 double;
    set CuocPhi = (select tinhCuocPhi(SoLuongVT, MaTrongTai, MaLoTrinh)
        from chitietvantai
        where chitietvantai.MaLoTrinh = MaLoTrinh and YEAR(NgayDen) = NamVanTai
        group by chitietvantai.MaLoTrinh);

    set Thuong1 = (select tinhThuong1(NgayDi, NgayDen, SoLuongVT, MaTrongTai, MaLoTrinh)
        from chitietvantai
        where chitietvantai.MaLoTrinh = MaLoTrinh and YEAR(NgayDen) = NamVanTai
        group by chitietvantai.MaLoTrinh);

    set result = (select SUM(CuocPhi+Thuong1));

end //
delimiter ;
call TinhTienTheoMaLoTrinhVaNam(9,2021,@result);
select @result;

# 9. Tạo thủ tục có đầu vào là số xe, năm vận tải, đầu ra là số tiền theo mã lộ trình đó
delimiter //
drop procedure if exists TinhTienTheoSoXeVaNam;
create procedure TinhTienTheoSoXeVaNam(In SoXe varchar(20), in NamVanTai int, out result double)
begin
    declare CuocPhi double;
    declare Thuong1 double;
    set CuocPhi = (select tinhCuocPhi(SoLuongVT, MaTrongTai, MaLoTrinh)
                   from chitietvantai
                   where chitietvantai.Soxe = Soxe and YEAR(NgayDen) = NamVanTai
                   group by chitietvantai.Soxe);

    set Thuong1 = (select tinhThuong1(NgayDi, NgayDen, SoLuongVT, MaTrongTai, MaLoTrinh)
                   from chitietvantai
                   where chitietvantai.Soxe = Soxe and YEAR(NgayDen) = NamVanTai
                   group by chitietvantai.Soxe);

    set result = (select SUM(CuocPhi+Thuong1));

end //
delimiter ;
call TinhTienTheoSoXeVaNam(9,2020,@result);
select @result;
#10 Tạo thủ tục có đầu vào là Ngày đi , ngày đến đầu ra là thông tin chi tiết vận tải
delimiter //
drop procedure if exists XemThongTinVanTai;
create procedure XemThongTinVanTai(In Ngaydi datetime,In Ngayden datetime)
begin
   if Ngaydi is null and Ngayden is null then select * from chitietvantai;
       elseif Ngayden is null and Ngaydi is not null then select * from chitietvantai where chitietvantai.NgayDi = NgayDi;
       elseif Ngayden is not null and Ngaydi is null then select * from chitietvantai where chitietvantai.NgayDen = NgayDen;
       else select * from chitietvantai where chitietvantai.NgayDen = NgayDen and chitietvantai.NgayDi = NgayDi;
   end if ;
end //
delimiter ;
call XemThongTinVanTai(null,null)