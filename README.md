# K8s on AWS — Terraform 1-Click Challenge 🚀

Dự án này là lời giải cho thử thách: **Tự động hoá 100% bằng Terraform để triển khai cụm K8s (kind) trên EC2, sau đó chạy ứng dụng Mini Dashboard và expose nó ra Internet thông qua AWS Application Load Balancer.**

## 🌟 Tính năng kỹ thuật nổi bật

1. **Automation 100%**: Chỉ cần đúng một lệnh `terraform apply`, hệ thống sẽ tự thiết lập mọi thứ từ Network, Security, EC2, cho tới Kubernetes và App. Không cần SSH vào server một lần nào.
2. **Kỹ thuật `templatefile` và `base64` siêu việt**: Thay vì phải đẩy code Mini Dashboard lên Github hay dùng `provisioner` rắc rối, hệ thống dùng Terraform đọc nội dung file cục bộ tại thư mục `app/`, mã hoá Base64 và nhúng thẳng vào `user_data.sh`. Khi EC2 khởi động, nó tự giải mã, sinh ra file và build Docker Image ngay lập tức.
3. **Multi-provider**: Kết hợp `aws` (tạo hạ tầng) và `null` (mô phỏng thời gian chờ logic) để đáp ứng yêu cầu dùng từ 2 provider trở lên.
4. **App chuẩn K8s**: Dùng Mini Dashboard có `data.json` mock, được Dockerize bởi Nginx. Deploy bằng Kubernetes `Deployment` và `Service (NodePort)`.

## 🏗 Kiến trúc Hệ thống

```mermaid
graph TD
    User([Người dùng Internet]) -->|Truy cập URL Port 80| ALB(AWS Application Load Balancer)
    ALB -->|Target Group Port 30000| EC2[EC2 Instance t3.medium]
    
    subgraph K8s Cluster [Cụm Kubernetes (kind) chạy trong EC2]
        NodePort[K8s Service: NodePort 30000]
        NodePort -->|Cân bằng tải| Pod1(Mini Dashboard Pod)
        NodePort -->|Cân bằng tải| Pod2(Mini Dashboard Pod)
    end
    
    EC2 --> NodePort
```

## 🚀 Hướng dẫn chạy (1-Click)

**Yêu cầu:** Máy tính đã cài đặt Terraform và cấu hình sẵn AWS CLI (`aws configure`).

**Bước 1: Khởi tạo Terraform**
Mở terminal tại thư mục này và gõ:
```bash
terraform init
```

**Bước 2: Triển khai 1-Click**
```bash
terraform apply -auto-approve
```

**Bước 3: Tận hưởng kết quả**
- Chờ Terraform chạy xong (khoảng 1 phút). Nó sẽ in ra trên màn hình một dòng `alb_dns_name = "http://k8s-app-alb-xxxx.ap-southeast-1.elb.amazonaws.com"`.
- Vì EC2 cần khoảng **3 - 4 phút** để tải Docker, cài đặt K8s `kind`, build Docker image và nạp vào cụm, bạn hãy chờ chút xíu.
- Mở link ở Output trên bằng trình duyệt, bạn sẽ thấy giao diện Mini Dashboard tuyệt đẹp của mình!

## 🧹 Dọn dẹp
Sau khi chạy và test xong, gõ lệnh sau để xoá hoàn toàn hệ thống, tránh phát sinh chi phí:
```bash
terraform destroy -auto-approve
```
