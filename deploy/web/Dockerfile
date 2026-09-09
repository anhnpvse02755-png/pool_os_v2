# Bundle web đã build sẵn ở máy dev rồi commit vào nhánh deploy.
# Cố ý KHÔNG build Flutter trong image: VPS chỉ có 2 vCPU và đang chạy
# production, build ở đây vừa chậm vừa tranh tài nguyên với cms/website.
FROM nginx:1.27-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY web/ /usr/share/nginx/html/
EXPOSE 80
