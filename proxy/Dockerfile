# Gunakan image Node.js LTS terbaru (misalnya versi 20 atau 22) dengan varian Alpine untuk ukuran yang lebih kecil
FROM node:20-alpine

# Set direktori kerja di dalam container
WORKDIR /usr/src/app

# Salin package.json dan package-lock.json terlebih dahulu untuk memanfaatkan caching Docker layer
COPY package*.json ./

# Instal dependensi aplikasi
RUN npm install

# Salin sisa kode aplikasi ke direktori kerja
# Ini akan menyalin semua file dan folder dari konteks build (direktori tempat Dockerfile berada, atau yang Anda tentukan di cloudbuild.yaml)
COPY . .

# Expose port yang digunakan aplikasi Anda
# Ini cocok dengan `const PORT = process.env.PORT || 3001;` di kode Node.js Anda
EXPOSE 3001

# Perintah untuk menjalankan aplikasi ketika container dimulai
# Pastikan 'index.js' adalah nama file utama aplikasi Anda
CMD ["node", "index.js"]