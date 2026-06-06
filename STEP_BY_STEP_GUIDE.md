# Hướng Dẫn Từng Bước (Step-by-Step Guide)

File này lưu lại toàn bộ các lệnh bạn cần gõ cho project này. Tôi sẽ cập nhật thêm các lệnh tiếp theo sau khi bạn hoàn thành lệnh hiện tại.

---

## ✅ BƯỚC 1: Xử lý lỗi xác thực AWS (ĐÃ HOÀN THÀNH)

**Lệnh đã gõ:**
```bash
aws configure
```

**Mục đích:** 
Lỗi `InvalidClientTokenId` báo hiệu rằng máy tính của bạn chưa có thông tin đăng nhập AWS, hoặc thông tin cũ đã bị hết hạn. Lệnh này sẽ yêu cầu bạn nhập lại 4 thông tin:
1. `AWS Access Key ID`: (Lấy từ giao diện IAM của AWS)
2. `AWS Secret Access Key`: (Lấy từ giao diện IAM của AWS)
3. `Default region name`: Nhập `ap-southeast-1` (Vùng Singapore)
4. `Default output format`: Nhập `json`

---

## ✅ BƯỚC 2: Khởi tạo Terraform (ĐÃ HOÀN THÀNH)

**Lệnh đã gõ:**
```bash
terraform init
```

**Mục đích:** 
Đoạn code của chúng ta yêu cầu kết nối với AWS và cần dùng hàm `null` của Terraform. Lệnh này sẽ yêu cầu Terraform kết nối mạng và tải các thư viện (providers) cần thiết về máy của bạn (nó sẽ tự sinh ra thư mục `.terraform`). 

---

## ✅ BƯỚC 3: Xem trước hạ tầng (ĐÃ HOÀN THÀNH)

**Lệnh đã gõ:**
```bash
terraform plan
```

**Mục đích:** 
Terraform cực kỳ an toàn. Lệnh này KHÔNG tạo ra cái gì trên AWS cả, nó chỉ "mô phỏng" để cho bạn biết trước nó dự định sẽ làm những gì. Lệnh này sẽ quét toàn bộ file `.tf` của chúng ta, đối chiếu với AWS và in ra một bản báo cáo dài thòng. 

---

## ✅ BƯỚC 4: Bấm Nút Phóng (ĐÃ HOÀN THÀNH)

**Lệnh đã gõ:**
```bash
terraform apply -auto-approve
```

**Mục đích:** 
Lệnh này chính là cốt lõi của bài Challenge "1-Click". Nó sẽ đọc code trong `main.tf` và bắt đầu gọi API của AWS để dựng máy chủ EC2, dựng Load Balancer, Security Group, và tự động truyền code `user_data` vào EC2. Chữ `-auto-approve` để bảo Terraform: *"Cứ làm đi, tao tin mày, không cần xác nhận Y/N nữa"*.

---

## 🧹 BƯỚC 5: Dọn dẹp tài nguyên (Destroy)

**Lệnh cần gõ:**
```bash
terraform destroy -auto-approve
```

**Mục đích:** 
AWS tính tiền theo từng phút bạn mở máy chủ. Sau khi bạn đã truy cập được link ALB, xem tận mắt giao diện Mini Dashboard và chụp hình lại nộp bài, bạn **BẮT BUỘC** phải chạy lệnh này.

Lệnh này đi ngược lại hoàn toàn với lệnh `apply`, nó sẽ quét toàn bộ những gì nãy giờ tạo ra (EC2, Load Balancer, Security Group) và xoá sạch bong không để lại dấu vết. Đảm bảo tài khoản AWS của bạn an toàn không bị trừ xu nào!

Gõ xong lệnh này là coi như bạn chính thức TỐT NGHIỆP CÁI CHALLENGE NÀY! 🎉
