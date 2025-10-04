# Soyjak Survivors - โปรเจกต์เกม RPG

## คำอธิบายโปรเจกต์

โปรเจกต์นี้เป็นเกม RPG แบบ Web-based ที่พัฒนาด้วย Node.js, Express และ MySQL สำหรับวิชาฐานข้อมูล ผู้เล่นสามารถสร้างตัวละคร เลเวลอัพ จัดการอุปกรณ์ และดูสถิติต่างๆ ได้

## ฟีเจอร์หลัก

- **ระบบล็อกอิน/ลงทะเบียน** - ผู้เล่นสามารถสร้างบัญชีและเข้าสู่ระบบ
- **เลือกตัวละคร** - มีตัวละครหลายคลาสให้เลือก แต่ละตัวมีสถิติและความสามารถต่างกัน
- **ระบบเลเวล & XP** - เพิ่มประสบการณ์เพื่ออัพเลเวล ปลดล็อกอุปกรณ์ใหม่ๆ
- **จัดการอุปกรณ์** - สวมใส่อุปกรณ์ต่างๆ (หมวก เกราะ กางเกง อาวุธ)
- **Dashboard** - ดูข้อมูลในฐานข้อมูลแบบเรียลไทม์
- **SQL Query Log** - ดูคำสั่ง SQL ที่ทำงานแบบเรียลไทม์

## เทคโนโลยีที่ใช้

- **Backend**: Node.js + Express.js
- **Database**: MySQL
- **Frontend**: HTML, CSS (Custom), Vanilla JavaScript
- **Session Management**: express-session
- **Environment Variables**: dotenv

## โครงสร้างฐานข้อมูล

### ตารางหลัก

1. **player** - ข้อมูลผู้เล่น
2. **character_template** - แม่แบบตัวละคร
3. **charactertable** - ตัวละครของผู้เล่น
4. **classtable** - คลาสตัวละคร
5. **equipment** - อุปกรณ์ทั้งหมด
6. **characterequipment** - อุปกรณ์ที่สวมใส่
7. **characterstats** - สถิติตัวละคร
8. **leveltable** - ข้อมูลเลเวล
9. **stat** - ประเภทสถิติ
10. **slottype** - ประเภทช่องอุปกรณ์
11. **template_base_stats** - สถิติเริ่มต้นของแต่ละแม่แบบ

## การติดตั้ง

### 1. Clone Repository

```bash
git clone <repository-url>
cd soyjak-survivors
```

### 2. ติดตั้ง Dependencies

```bash
npm install
```

### 3. ตั้งค่า Environment Variables

สร้างไฟล์ `.env` ในโฟลเดอร์หลัก:

```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=soyjak_party_DB
DB_PORT=3306
SESSION_SECRET=your_secret_key_here
PORT=3000
```

### 4. Import ฐานข้อมูล

```bash
mysql -u root -p soyjak_party_DB < database.sql
```

### 5. รันโปรเจกต์

```bash
npm start
```

เปิดเบราว์เซอร์ที่ `http://localhost:3000`

## โครงสร้างโฟลเดอร์

```
soyjak-survivors/
├── public/
│   ├── css/
│   │   └── style.css          # สไตล์ทั้งหมด
│   ├── js/
│   │   ├── game.js            # Logic เกมหลัก
│   │   └── dashboard.js       # Logic dashboard
│   └── images/                # รูปภาพ background และตัวละคร
├── views/
│   ├── login.html             # หน้าล็อกอิน
│   ├── game.html              # หน้าเกมหลัก
│   └── dashboard.html         # หน้า dashboard
├── server.js                  # Express server หลัก
├── package.json
└── .env                       # Environment variables
```

## API Endpoints

### Authentication
- `POST /api/login` - ล็อกอิน
- `POST /api/register` - ลงทะเบียน
- `POST /api/logout` - ออกจากระบบ

### Character Management
- `GET /api/characters` - ดึงรายการตัวละครทั้งหมด
- `POST /api/character/select` - เลือก/สร้างตัวละคร
- `GET /api/character/:id` - ดึงข้อมูลตัวละคร
- `DELETE /api/character/:charId` - รีเซ็ตตัวละคร

### Equipment
- `GET /api/equipment` - ดึงรายการอุปกรณ์
- `POST /api/equip` - สวมใส่อุปกรณ์
- `POST /api/unequip` - ถอดอุปกรณ์

### XP System
- `POST /api/addxp` - เพิ่ม XP
- `POST /api/reducexp` - ลด XP

### Dashboard
- `GET /api/dashboard/:tableName` - ดึงข้อมูลตาราง
- `GET /api/sql-log` - ดู SQL queries
- `POST /api/sql-log/clear` - ล้าง log

## ฟีเจอร์พิเศษ

### SQL Query Terminal
แสดงคำสั่ง SQL แบบเรียลไทม์ที่ทำงานในเกม:
- จัดกลุ่มตาม API endpoint
- แสดง timestamp และ parameters
- สามารถ expand/collapse แต่ละกลุ่ม
- ล้าง log ได้

### Character Progression
- เริ่มที่เลเวล 1
- ได้รับ 50 XP ต่อครั้ง
- อุปกรณ์บางชิ้นต้องการเลเวลขั้นต่ำ
- สถิติเพิ่มขึ้นตามอุปกรณ์ที่สวมใส่

### Database Dashboard
- ดูข้อมูลในทุกตารางแบบ read-only
- Refresh ข้อมูลแบบเรียลไทม์
- UI สวยงาม เข้าธีมเกม

## คำแนะนำการใช้งาน

1. **สร้างบัญชี** - กรอก username และ email
2. **เลือกตัวละคร** - คลิกที่ตัวละครที่ต้องการ
3. **เพิ่ม XP** - กดปุ่ม "Add 50 XP" เพื่ออัพเลเวล
4. **จัดการอุปกรณ์** - คลิกที่อุปกรณ์เพื่อดูรายละเอียดและสวมใส่
5. **ดู Dashboard** - คลิกปุ่ม "Dashboard" เพื่อดูฐานข้อมูล

## Features โดดเด่น

- **Responsive Design** - ใช้งานได้ทั้ง Desktop และ Mobile
- **Real-time Updates** - ข้อมูลอัพเดททันที
- **Beautiful UI** - ธีมสีทองคลาสสิก แบบ Medieval RPG
- **Security** - Session management และ SQL injection protection
- **Performance** - Connection pooling สำหรับฐานข้อมูล

## หมายเหตุ

- โปรเจกต์นี้พัฒนาเพื่อการศึกษาเท่านั้น
- ไม่แนะนำให้ใช้ใน production โดยตรง
- รูปภาพและชื่อตัวละครเป็นเพียงตัวอย่าง

## ปัญหาที่พบบ่อย

**Q: ฐานข้อมูลเชื่อมต่อไม่ได้**  
A: ตรวจสอบไฟล์ `.env` และแน่ใจว่า MySQL ทำงานอยู่

**Q: Session หมดอายุเร็ว**  
A: แก้ไข `cookie.maxAge` ใน `server.js`

**Q: ภาพไม่โหลด**  
A: ตรวจสอบว่าไฟล์ภาพอยู่ในโฟลเดอร์ `public/images/`

## License

MIT License - ใช้งานได้ตามต้องการ

## ผู้พัฒนา

นายปรานต์ มีเดช รหัสนักศึกษา 67543210003-9
นายสิริ รัตนรินทร์ รหัสนักศึกษา 64505142056-2

---

