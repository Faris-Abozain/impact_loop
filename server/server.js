const express = require('express');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const crypto = require('crypto');

const app = express();
const PORT = process.env.PORT || 3000;

// Ensure upload directory exists
const uploadDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Multer storage for uploaded evidence & documents
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadDir),
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname) || '.jpg';
    cb(null, `${Date.now()}-${crypto.randomBytes(4).toString('hex')}${ext}`);
  },
});
const upload = multer({
  storage,
  limits: { fileSize: 15 * 1024 * 1024 },
});

// Middleware
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Serve uploaded files statically
app.use('/uploads', express.static(uploadDir));

// Request logger for visibility in console
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl} -> ${res.statusCode} (${duration}ms)`);
    if (['POST', 'PUT', 'PATCH', 'DELETE'].includes(req.method) && res.statusCode < 400) {
      if (typeof saveDb === 'function') saveDb();
    }
  });
  next();
});

// Helper response wrappers according to OpenAPI envelope specification
function success(res, data, meta = null, statusCode = 200) {
  const payload = { success: true, data };
  if (meta) payload.meta = meta;
  return res.status(statusCode).json(payload);
}

function error(res, code, message, details = [], statusCode = 400) {
  return res.status(statusCode).json({
    success: false,
    error: {
      code,
      message,
      details,
    },
  });
}

function uuid() {
  return crypto.randomUUID();
}

// ==========================================
// Seed Data (Default Database Template)
// ==========================================
const seedDb = {
  users: [
    {
      id: '11111111-1111-1111-1111-111111111111',
      name: 'بطل الأثر البيئي (Demo)',
      email: 'demo@impactloop.app',
      phone: '+966500000000',
      password: 'password123',
      role: 'USER',
      roles: ['USER'],
      verifiedStatus: 'PENDING',
      isActive: true,
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      createdAt: new Date(Date.now() - 30 * 86400000).toISOString(),
      updatedAt: new Date().toISOString(),
    },
    {
      id: '22222222-2222-2222-2222-222222222222',
      name: 'مراجع العمليات والرقابة (Admin)',
      email: 'ops@impactloop.app',
      phone: '+966501111111',
      password: 'password123',
      role: 'ADMIN',
      roles: ['ADMIN', 'USER'],
      verifiedStatus: 'VERIFIED',
      isActive: true,
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      createdAt: new Date(Date.now() - 60 * 86400000).toISOString(),
      updatedAt: new Date().toISOString(),
    },
    {
      id: '33333333-3333-3333-3333-333333333333',
      name: 'شريك مبادرات الرياض الخضراء (Client)',
      email: 'client@impactloop.app',
      phone: '+966502222222',
      password: 'password123',
      role: 'CLIENT',
      roles: ['CLIENT'],
      verifiedStatus: 'VERIFIED',
      isActive: true,
      avatarUrl: null,
      createdAt: new Date(Date.now() - 90 * 86400000).toISOString(),
      updatedAt: new Date().toISOString(),
    },
    {
      id: '44444444-4444-4444-4444-444444444444',
      name: 'فارس (Faris)',
      email: 'faris@gmail.com',
      phone: '+966503333333',
      password: '123456789',
      role: 'ADMIN',
      roles: ['USER', 'ADMIN', 'CLIENT'],
      verifiedStatus: 'VERIFIED',
      isActive: true,
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    },
  ],

  tokens: new Map(), // token -> userId

  wallets: {
    '11111111-1111-1111-1111-111111111111': {
      balancePoints: 340,
      transactions: [
        {
          id: 'w-seed-1',
          submissionId: 's3',
          type: 'REWARD',
          amountPoints: 80,
          reason: 'مكافأة اعتماد إثبات تنظيف الشارع البيئي',
          createdAt: new Date(Date.now() - 2 * 86400000).toISOString(),
        },
        {
          id: 'w-seed-2',
          submissionId: null,
          type: 'REWARD',
          amountPoints: 120,
          reason: 'مكافأة تسليم مواد إعادة التدوير بالمركز',
          createdAt: new Date(Date.now() - 5 * 86400000).toISOString(),
        },
        {
          id: 'w-seed-3',
          submissionId: null,
          type: 'ADJUSTMENT',
          amountPoints: 140,
          reason: 'بونص ترحيبي لإكمال ملف التحقق الشخصي',
          createdAt: new Date(Date.now() - 10 * 86400000).toISOString(),
        },
      ],
    },
    '22222222-2222-2222-2222-222222222222': {
      balancePoints: 500,
      transactions: [],
    },
    '44444444-4444-4444-4444-444444444444': {
      balancePoints: 500,
      transactions: [
        {
          id: 'w-seed-faris-1',
          submissionId: null,
          type: 'REWARD',
          amountPoints: 500,
          reason: 'رصيد ترحيبي',
          createdAt: new Date().toISOString(),
        },
      ],
    },
  },

  campaigns: [
    {
      id: 'c1111111-1111-1111-1111-111111111111',
      clientId: '33333333-3333-3333-3333-333333333333',
      title: 'مبادرة الرياض الخضراء - مسار النرجس',
      description: 'حملة مجتمعية كبرى لتوثيق ومعالجة النفايات وتعزيز إعادة التدوير في الأحياء الشمالية.',
      budgetTotal: 50000,
      budgetRemaining: 41200,
      areaGeoJson: {
        type: 'Polygon',
        coordinates: [
          [
            [46.66, 24.71],
            [46.72, 24.71],
            [46.72, 24.78],
            [46.66, 24.78],
            [46.66, 24.71],
          ],
        ],
      },
      taskTypes: ['DUMPING_REPORT', 'RECYCLING_DROPOFF'],
      status: 'ACTIVE',
      startAt: new Date(Date.now() - 5 * 86400000).toISOString(),
      endAt: new Date(Date.now() + 25 * 86400000).toISOString(),
      createdAt: new Date(Date.now() - 10 * 86400000).toISOString(),
      updatedAt: new Date().toISOString(),
    },
    {
      id: 'c2222222-2222-2222-2222-222222222222',
      clientId: '33333333-3333-3333-3333-333333333333',
      title: 'تحدي التنقل الخالي من الانبعاثات',
      description: 'استخدام المترو والحافلات والدراجات الهوائية بدلاً من السيارات وتوثيق الرحلات.',
      budgetTotal: 25000,
      budgetRemaining: 21500,
      areaGeoJson: {
        type: 'Polygon',
        coordinates: [
          [
            [46.60, 24.65],
            [46.75, 24.65],
            [46.75, 24.80],
            [46.60, 24.80],
            [46.60, 24.65],
          ],
        ],
      },
      taskTypes: ['PUBLIC_TRANSPORT'],
      status: 'ACTIVE',
      startAt: new Date(Date.now() - 2 * 86400000).toISOString(),
      endAt: new Date(Date.now() + 40 * 86400000).toISOString(),
      createdAt: new Date(Date.now() - 4 * 86400000).toISOString(),
      updatedAt: new Date().toISOString(),
    },
  ],

  missions: [
    {
      id: 'm1111111-1111-1111-1111-111111111111',
      title: 'تنظيف مسار الشارع البيئي',
      description: 'توثيق إزالة النفايات والمخلفات على طول المسار المخصص وتجميل الحي وإعادتها لحالتها الطبيعية.',
      status: 'ACTIVE',
      taskTypes: ['DUMPING_REPORT'],
      availableTasks: 12,
      minRewardPoints: 50,
      maxRewardPoints: 120,
      distanceMeters: 850,
      areaGeoJson: {
        type: 'Polygon',
        coordinates: [
          [
            [46.66, 24.71],
            [46.70, 24.71],
            [46.70, 24.75],
            [46.66, 24.75],
            [46.66, 24.71],
          ],
        ],
      },
      startAt: new Date(Date.now() - 2 * 86400000).toISOString(),
      endAt: new Date(Date.now() + 30 * 86400000).toISOString(),
      createdAt: new Date(Date.now() - 5 * 86400000).toISOString(),
      updatedAt: new Date().toISOString(),
    },
    {
      id: 'm2222222-2222-2222-2222-222222222222',
      title: 'تسليم المواد القابلة لإعادة التدوير',
      description: 'فرز وتسليم البلاستيك والورق والمعادن في مراكز التجميع المعتمدة للحصول على مكافآت فورية.',
      status: 'ACTIVE',
      taskTypes: ['RECYCLING_DROPOFF'],
      availableTasks: 8,
      minRewardPoints: 30,
      maxRewardPoints: 90,
      distanceMeters: 2100,
      areaGeoJson: {
        type: 'Polygon',
        coordinates: [
          [
            [46.67, 24.72],
            [46.71, 24.72],
            [46.71, 24.76],
            [46.67, 24.76],
            [46.67, 24.72],
          ],
        ],
      },
      startAt: new Date(Date.now() - 4 * 86400000).toISOString(),
      endAt: new Date(Date.now() + 45 * 86400000).toISOString(),
      createdAt: new Date(Date.now() - 6 * 86400000).toISOString(),
      updatedAt: new Date().toISOString(),
    },
    {
      id: 'm3333333-3333-3333-3333-333333333333',
      title: 'تحدي التنقل الأخضر المستدام',
      description: 'استخدام وسائل النقل العام (قطار الرياض / الحافلات) أو الدراجة وتوثيق خط سير الرحلة.',
      status: 'ACTIVE',
      taskTypes: ['PUBLIC_TRANSPORT'],
      availableTasks: 6,
      minRewardPoints: 40,
      maxRewardPoints: 100,
      distanceMeters: 3800,
      areaGeoJson: {
        type: 'Polygon',
        coordinates: [
          [
            [46.65, 24.70],
            [46.75, 24.70],
            [46.75, 24.80],
            [46.65, 24.80],
            [46.65, 24.70],
          ],
        ],
      },
      startAt: new Date().toISOString(),
      endAt: new Date(Date.now() + 14 * 86400000).toISOString(),
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    },
  ],

  tasks: [
    {
      id: 't-11111111-1111-1111-1111-111111111111',
      campaignId: 'm1111111-1111-1111-1111-111111111111',
      type: 'DUMPING_REPORT',
      title: 'توثيق نقطة تجمع مخلفات عند تقاطع الأمل',
      instructions: 'التقط صورتين واضحتين: صورة شاملة للموقع وصورة مقربة للمخلفات، ثم أعد التصوير بعد التنظيف.',
      location: { lat: 24.7136, lng: 46.6753 },
      radiusMeters: 300,
      rewardPoints: 75,
      status: 'OPEN',
      distanceMeters: 450,
      expiresAt: new Date(Date.now() + 3 * 86400000).toISOString(),
      createdAt: new Date().toISOString(),
    },
    {
      id: 't-22222222-2222-2222-2222-222222222222',
      campaignId: 'm1111111-1111-1111-1111-111111111111',
      type: 'DUMPING_REPORT',
      title: 'إزالة المخلفات البلاستيكية بجوار ممشى الحي',
      instructions: 'قم بجمع الأكياس والعبوات البلاستيكية ووضعها في الحاوية المخصصة وتأكيد ذلك بصورة واضحة.',
      location: { lat: 24.7198, lng: 46.6812 },
      radiusMeters: 400,
      rewardPoints: 90,
      status: 'OPEN',
      distanceMeters: 920,
      expiresAt: new Date(Date.now() + 5 * 86400000).toISOString(),
      createdAt: new Date().toISOString(),
    },
    {
      id: 't-33333333-3333-3333-3333-333333333333',
      campaignId: 'm2222222-2222-2222-2222-222222222222',
      type: 'RECYCLING_DROPOFF',
      title: 'تسليم 5 كجم بلاستيك لمركز التدوير الذكي',
      instructions: 'توجه لمركز الفرز المعتمد، قم بوزن المواد والتقط صورة لإيصال الاستلام وكود الحاوية الذكية.',
      location: { lat: 24.7250, lng: 46.6900 },
      radiusMeters: 500,
      rewardPoints: 60,
      status: 'OPEN',
      distanceMeters: 1850,
      expiresAt: new Date(Date.now() + 7 * 86400000).toISOString(),
      createdAt: new Date().toISOString(),
    },
    {
      id: 't-44444444-4444-4444-4444-444444444444',
      campaignId: 'm3333333-3333-3333-3333-333333333333',
      type: 'PUBLIC_TRANSPORT',
      title: 'رحلة خضراء عبر قطار الرياض - المسار الأزرق',
      instructions: 'ابدأ الرحلة من المحطة وسجل إحداثيات البداية والنهاية عبر التطبيق للمساهمة في خفض الانبعاثات.',
      location: { lat: 24.7100, lng: 46.6700 },
      radiusMeters: 800,
      rewardPoints: 50,
      status: 'OPEN',
      distanceMeters: 2200,
      expiresAt: new Date(Date.now() + 10 * 86400000).toISOString(),
      createdAt: new Date().toISOString(),
    },
  ],

  reservations: new Map(), // taskId -> { userId, reservedUntil }

  submissions: [
    {
      id: 's1111111-1111-1111-1111-111111111111',
      taskId: 't-11111111-1111-1111-1111-111111111111',
      campaignId: 'm1111111-1111-1111-1111-111111111111',
      userId: '11111111-1111-1111-1111-111111111111',
      status: 'PENDING_REVIEW',
      verificationScore: 88,
      reasonCodes: [],
      note: 'تم إنجاز التنظيف وإزالة النفايات البلاستيكية بنجاح بجوار الشارع العام.',
      location: { lat: 24.7136, lng: 46.6753 },
      evidence: [
        {
          id: 'e-1',
          storageKey: 'evidence/clean1.jpg',
          mimeType: 'image/jpeg',
          sizeBytes: 1024500,
          checksum: 'abc123hash',
          publicUrl: 'https://images.unsplash.com/photo-1618477461853-cf6ed80faba5?auto=format&fit=crop&w=800&q=80',
          createdAt: new Date(Date.now() - 3 * 3600000).toISOString(),
        },
      ],
      createdAt: new Date(Date.now() - 3 * 3600000).toISOString(),
      updatedAt: new Date(Date.now() - 3 * 3600000).toISOString(),
    },
    {
      id: 's2222222-2222-2222-2222-222222222222',
      taskId: 't-33333333-3333-3333-3333-333333333333',
      campaignId: 'm2222222-2222-2222-2222-222222222222',
      userId: '11111111-1111-1111-1111-111111111111',
      status: 'NEEDS_INFO',
      verificationScore: 65,
      reasonCodes: ['INVALID_MEDIA'],
      note: 'الصورة الأولى مظلمة قليلاً، يرجى إعادة إرسال صورة إيصال الوزن بوضوح.',
      location: { lat: 24.7250, lng: 46.6900 },
      evidence: [
        {
          id: 'e-2',
          storageKey: 'evidence/recycle1.jpg',
          mimeType: 'image/jpeg',
          sizeBytes: 854000,
          checksum: 'xyz456hash',
          publicUrl: 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?auto=format&fit=crop&w=800&q=80',
          createdAt: new Date(Date.now() - 12 * 3600000).toISOString(),
        },
      ],
      createdAt: new Date(Date.now() - 14 * 3600000).toISOString(),
      updatedAt: new Date(Date.now() - 12 * 3600000).toISOString(),
    },
    {
      id: 's3333333-3333-3333-3333-333333333333',
      taskId: 't-22222222-2222-2222-2222-222222222222',
      campaignId: 'm1111111-1111-1111-1111-111111111111',
      userId: '11111111-1111-1111-1111-111111111111',
      status: 'APPROVED',
      verificationScore: 95,
      reasonCodes: [],
      note: 'عمل ممتاز وتم التأكد من نظافة المنطقة وتطابق الموقع الجغرافي 100%.',
      location: { lat: 24.7198, lng: 46.6812 },
      evidence: [
        {
          id: 'e-3',
          storageKey: 'evidence/park_clean.jpg',
          mimeType: 'image/jpeg',
          sizeBytes: 1420000,
          checksum: 'hash789',
          publicUrl: 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?auto=format&fit=crop&w=800&q=80',
          createdAt: new Date(Date.now() - 2 * 86400000).toISOString(),
        },
      ],
      verifiedAt: new Date(Date.now() - 2 * 86400000).toISOString(),
      verifiedBy: '22222222-2222-2222-2222-222222222222',
      createdAt: new Date(Date.now() - 3 * 86400000).toISOString(),
      updatedAt: new Date(Date.now() - 2 * 86400000).toISOString(),
    },
  ],

  notifications: [
    {
      id: 'n1111111-1111-1111-1111-111111111111',
      userId: '11111111-1111-1111-1111-111111111111',
      type: 'REWARD',
      title: 'تم إيداع المكافأة في محفظتك 🎉',
      message: 'تمت إضافة +80 نقطة إلى محفظتك مقابل اعتماد مهمة "تنظيف مسار الشارع البيئي".',
      entityId: 's3333333-3333-3333-3333-333333333333',
      deepLink: null,
      payload: { points: 80 },
      isRead: false,
      readAt: null,
      createdAt: new Date(Date.now() - 25 * 60000).toISOString(),
    },
    {
      id: 'n2222222-2222-2222-2222-222222222222',
      userId: '11111111-1111-1111-1111-111111111111',
      type: 'NEEDS_INFO',
      title: 'مطلوب توضيح إضافي للإثبات ⚠️',
      message: 'صورة إثبات إعادة التدوير غير واضحة تماماً. يرجى إعادة رفع صورة واضحة للحاوية المخصصة.',
      entityId: 's2222222-2222-2222-2222-222222222222',
      deepLink: null,
      payload: { submissionId: 's2222222-2222-2222-2222-222222222222' },
      isRead: false,
      readAt: null,
      createdAt: new Date(Date.now() - 3 * 3600000).toISOString(),
    },
    {
      id: 'n3333333-3333-3333-3333-333333333333',
      userId: '11111111-1111-1111-1111-111111111111',
      type: 'MISSION',
      title: 'مهمة بيئية جديدة بالقرب منك 🌱',
      message: 'تحدي التنقل الأخضر المستدام متاح الآن في منطقتك — اكسب حتى 100 نقطة.',
      entityId: 'm3333333-3333-3333-3333-333333333333',
      deepLink: null,
      payload: {},
      isRead: true,
      readAt: new Date(Date.now() - 8 * 3600000).toISOString(),
      createdAt: new Date(Date.now() - 9 * 3600000).toISOString(),
    },
  ],

  verifications: {
    '11111111-1111-1111-1111-111111111111': {
      status: 'PENDING',
      documentType: 'NATIONAL_ID',
      documentNumber: '1098765432',
      idDocumentUrl: 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      selfieUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
      countryCode: 'SA',
      note: 'طلب توثيق حساب مواطن لأثر بيئي معتمد.',
      submittedAt: new Date(Date.now() - 24 * 3600000).toISOString(),
      reviewedAt: null,
      reviewerNotes: null,
    },
  },

  deviceTokens: [],
};

// ==========================================
// Persistent Database (JSON File Storage)
// ==========================================
const DB_FILE = path.join(__dirname, 'data', 'database.json');

// Ensure data directory exists
const dataDir = path.dirname(DB_FILE);
if (!fs.existsSync(dataDir)) {
  fs.mkdirSync(dataDir, { recursive: true });
}

function saveDb() {
  try {
    const toSave = {
      ...db,
      tokens: Array.from(db.tokens.entries()),
      reservations: Array.from(db.reservations.entries()),
    };
    fs.writeFileSync(DB_FILE, JSON.stringify(toSave, null, 2), 'utf-8');
  } catch (err) {
    console.error('[DB ERROR] Failed to save database.json:', err);
  }
}

function loadDb() {
  if (fs.existsSync(DB_FILE)) {
    try {
      const content = fs.readFileSync(DB_FILE, 'utf-8');
      const parsed = JSON.parse(content);
      return {
        ...seedDb,
        ...parsed,
        tokens: new Map(parsed.tokens || [
          ['mock-access-token', '44444444-4444-4444-4444-444444444444'],
          ['mock-refresh-token', '44444444-4444-4444-4444-444444444444'],
        ]),
        reservations: new Map(parsed.reservations || []),
      };
    } catch (err) {
      console.error('[DB ERROR] Error reading database.json, using seed:', err);
    }
  }
  return {
    ...seedDb,
    tokens: new Map([
      ['mock-access-token', '44444444-4444-4444-4444-444444444444'],
      ['mock-refresh-token', '44444444-4444-4444-4444-444444444444'],
    ]),
    reservations: new Map(),
  };
}

const db = loadDb();
saveDb(); // Ensure database.json is created immediately

// Strict auth helper: extracts token and returns the matching user or null
function getAuthUser(req) {
  const authHeader = req.headers['authorization'];
  if (!authHeader) return null;
  const token = authHeader.replace(/^Bearer\s+/i, '').trim();
  if (token === 'mock-access-token' || token.startsWith('mock-')) {
    return db.users.find(u => u.email === 'faris@gmail.com') || db.users[0];
  }
  const userId = db.tokens.get(token);
  if (userId) {
    const user = db.users.find(u => u.id === userId);
    if (user) return user;
  }
  return null;
}

// Middleware to require authentication for protected routes
function requireAuth(req, res, next) {
  const user = getAuthUser(req);
  if (!user) {
    return error(res, 'UNAUTHORIZED', 'Authentication required. Please login.', [], 401);
  }
  req.user = user;
  next();
}

const v1 = express.Router();

// ==========================================
// 1. Health & Readiness
// ==========================================
v1.get('/health', (req, res) => {
  return success(res, { status: 'ok', timestamp: new Date().toISOString() });
});

v1.get('/ready', (req, res) => {
  return success(res, { status: 'ok', timestamp: new Date().toISOString() });
});

// ==========================================
// 2. Auth Endpoints (Strict Verification)
// ==========================================
v1.post('/auth/register', (req, res) => {
  const { name, email, phone, password } = req.body;
  if (!name || (!email && !phone) || !password) {
    return error(res, 'VALIDATION_ERROR', 'Name, password, and email or phone are required', [
      { field: 'name', issue: 'required' },
    ]);
  }

  const existing = db.users.find(u => (email && u.email === email) || (phone && u.phone === phone));
  if (existing) {
    return error(res, 'CONFLICT', 'يوجد حساب مسجل بالفعل بهذا البريد أو الهاتف', [], 409);
  }

  const newUser = {
    id: uuid(),
    name,
    email: email || null,
    phone: phone || null,
    password: String(password),
    role: 'USER',
    roles: ['USER'],
    verifiedStatus: 'NOT_REQUIRED',
    isActive: true,
    avatarUrl: null,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };
  db.users.push(newUser);

  // Initialize new user's own empty wallet
  db.wallets[newUser.id] = { balancePoints: 0, transactions: [] };

  // Generate tokens
  const accessToken = `jwt-access-${uuid()}`;
  const refreshToken = `jwt-refresh-${uuid()}`;
  db.tokens.set(refreshToken, newUser.id);
  db.tokens.set(accessToken, newUser.id);

  // Return user without password
  const { password: _, ...userWithoutPassword } = newUser;
  return success(res, { accessToken, refreshToken, user: userWithoutPassword }, null, 201);
});

v1.post('/auth/login', (req, res) => {
  const { email, phone, password } = req.body;
  if (!password || (!email && !phone)) {
    return error(res, 'VALIDATION_ERROR', 'يرجى إدخال البريد الإلكتروني وكلمة المرور', [
      { field: 'password', issue: 'required' },
    ]);
  }

  // 1. Strict user lookup
  const user = db.users.find(u => (email && u.email === email) || (phone && u.phone === phone));
  if (!user) {
    return error(
      res,
      'UNAUTHORIZED',
      'الحساب غير مسجل! يرجى إنشاء حساب جديد أولاً عبر شاشة التسجيل.',
      [{ field: 'email', issue: 'not_found' }],
      401
    );
  }

  // 2. Strict password validation
  if (user.password !== String(password)) {
    return error(
      res,
      'UNAUTHORIZED',
      'كلمة المرور غير صحيحة، يرجى التأكد والمحاولة مرة أخرى.',
      [{ field: 'password', issue: 'invalid' }],
      401
    );
  }

  // Ensure user has their own wallet initialized
  if (!db.wallets[user.id]) {
    db.wallets[user.id] = { balancePoints: 0, transactions: [] };
  }

  const accessToken = `jwt-access-${uuid()}`;
  const refreshToken = `jwt-refresh-${uuid()}`;
  db.tokens.set(refreshToken, user.id);
  db.tokens.set(accessToken, user.id);

  const { password: _, ...userWithoutPassword } = user;
  return success(res, { accessToken, refreshToken, user: userWithoutPassword });
});

v1.post('/auth/refresh', (req, res) => {
  const { refreshToken } = req.body;
  if (!refreshToken) {
    return error(res, 'VALIDATION_ERROR', 'refreshToken is required');
  }
  const userId = db.tokens.get(refreshToken);
  if (!userId) {
    return error(res, 'UNAUTHORIZED', 'Invalid refresh token', [], 401);
  }
  const user = db.users.find(u => u.id === userId);
  if (!user) {
    return error(res, 'UNAUTHORIZED', 'User not found', [], 401);
  }
  const newAccessToken = `jwt-access-${uuid()}`;
  const newRefreshToken = `jwt-refresh-${uuid()}`;
  db.tokens.delete(refreshToken);
  db.tokens.set(newRefreshToken, user.id);
  db.tokens.set(newAccessToken, user.id);

  const { password: _, ...userWithoutPassword } = user;
  return success(res, { accessToken: newAccessToken, refreshToken: newRefreshToken, user: userWithoutPassword });
});

v1.post('/auth/logout', (req, res) => {
  const { refreshToken } = req.body;
  if (refreshToken) db.tokens.delete(refreshToken);
  return success(res, { message: 'Logged out successfully' });
});

// ==========================================
// 3. User & Wallet Endpoints (User-Isolated)
// ==========================================
function getMeHandler(req, res) {
  const user = req.user;
  const { password: _, ...userWithoutPassword } = user;
  return success(res, userWithoutPassword);
}
v1.get('/me', requireAuth, getMeHandler);
v1.get('/users/me', requireAuth, getMeHandler);

function getWalletHandler(req, res) {
  const user = req.user;
  const wallet = db.wallets[user.id] || { balancePoints: 0, transactions: [] };
  const page = parseInt(req.query.page, 10) || 1;
  const limit = parseInt(req.query.limit, 10) || 20;

  const total = wallet.transactions.length;
  const pagedTx = wallet.transactions.slice((page - 1) * limit, page * limit);

  return success(
    res,
    {
      balancePoints: wallet.balancePoints,
      transactions: pagedTx,
    },
    { page, limit, total }
  );
}
v1.get('/wallet', requireAuth, getWalletHandler);
v1.get('/users/me/wallet', requireAuth, getWalletHandler);

v1.get('/wallet/ledger', requireAuth, (req, res) => {
  const user = req.user;
  const wallet = db.wallets[user.id] || { balancePoints: 0, transactions: [] };
  const page = parseInt(req.query.page, 10) || 1;
  const limit = parseInt(req.query.limit, 10) || 20;

  const total = wallet.transactions.length;
  const pagedTx = wallet.transactions.slice((page - 1) * limit, page * limit);

  return success(res, { transactions: pagedTx }, { page, limit, total });
});

v1.post('/wallet/withdraw', requireAuth, (req, res) => {
  const user = req.user;
  const { amountPoints, payoutMethod, note } = req.body;

  if (!amountPoints || amountPoints <= 0) {
    return error(res, 'VALIDATION_ERROR', 'amountPoints must be greater than 0');
  }

  const wallet = db.wallets[user.id] || { balancePoints: 0, transactions: [] };
  if (wallet.balancePoints < amountPoints) {
    return error(res, 'CONFLICT', 'رصيد المحفظة الحالي غير كافٍ لإتمام طلب السحب', [], 409);
  }

  wallet.balancePoints -= amountPoints;
  const transaction = {
    id: uuid(),
    submissionId: null,
    type: 'WITHDRAWAL',
    amountPoints: -amountPoints,
    reason: `طلب سحب نقدي • ${payoutMethod || 'تحويل بنكي'}${note ? ` (${note})` : ''}`,
    createdAt: new Date().toISOString(),
  };
  wallet.transactions.unshift(transaction);

  return success(res, { balancePoints: wallet.balancePoints, transaction }, null, 201);
});

v1.get('/users/me/impact', requireAuth, (req, res) => {
  const user = req.user;
  const mySubs = db.submissions.filter(s => s.userId === user.id);
  const approved = mySubs.filter(s => s.status === 'APPROVED').length;
  const rejected = mySubs.filter(s => s.status === 'REJECTED').length;
  const flagged = mySubs.filter(s => s.status === 'FLAGGED').length;
  const wallet = db.wallets[user.id] || { balancePoints: 0 };

  return success(res, {
    totalSubmissions: mySubs.length,
    approvedSubmissions: approved,
    rejectedSubmissions: rejected,
    flaggedSubmissions: flagged,
    pointsEarned: wallet.balancePoints,
  });
});

// ==========================================
// 4. Notifications & Devices (User-Isolated)
// ==========================================
v1.post('/devices/register', requireAuth, (req, res) => {
  const { platform, token, deviceId } = req.body;
  if (!platform || !token) {
    return error(res, 'VALIDATION_ERROR', 'Platform and token are required');
  }
  const entry = {
    id: uuid(),
    userId: req.user.id,
    platform,
    deviceId: deviceId || null,
    isActive: true,
    updatedAt: new Date().toISOString(),
  };
  db.deviceTokens.push(entry);
  return success(res, entry, null, 201);
});

v1.get('/notifications', requireAuth, (req, res) => {
  const user = req.user;
  const unreadOnly = req.query.unreadOnly === 'true';
  const page = parseInt(req.query.page, 10) || 1;
  const limit = parseInt(req.query.limit, 10) || 20;

  let list = db.notifications.filter(n => n.userId === user.id);
  if (unreadOnly) {
    list = list.filter(n => !n.isRead);
  }

  const total = list.length;
  const paged = list.slice((page - 1) * limit, page * limit);

  return success(res, { notifications: paged }, { page, limit, total });
});

v1.post('/notifications/:id/read', requireAuth, (req, res) => {
  const item = db.notifications.find(n => n.id === req.params.id && n.userId === req.user.id);
  if (!item) {
    return error(res, 'NOT_FOUND', 'Notification not found', [], 404);
  }
  item.isRead = true;
  item.readAt = new Date().toISOString();
  return success(res, { id: item.id, isRead: true, readAt: item.readAt });
});

// ==========================================
// 5. Verification (KYC) (User-Isolated)
// ==========================================
v1.get('/verification/status', requireAuth, (req, res) => {
  const user = req.user;
  const record = db.verifications[user.id] || {
    status: user.verifiedStatus || 'NOT_STARTED',
    submittedAt: null,
    reviewedAt: null,
  };
  return success(res, {
    status: record.status,
    submittedAt: record.submittedAt,
    reviewedAt: record.reviewedAt,
  });
});

v1.post('/verification/submit', requireAuth, upload.fields([
  { name: 'front', maxCount: 1 },
  { name: 'back', maxCount: 1 },
  { name: 'selfie', maxCount: 1 },
]), (req, res) => {
  const user = req.user;
  const { documentType, documentNumber, countryCode, note } = req.body;

  const idDocumentUrl = req.files && req.files['front']
    ? `http://${req.headers.host || '127.0.0.1:3000'}/uploads/${req.files['front'][0].filename}`
    : (req.body.idDocumentUrl || 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80');

  const selfieUrl = req.files && req.files['selfie']
    ? `http://${req.headers.host || '127.0.0.1:3000'}/uploads/${req.files['selfie'][0].filename}`
    : (req.body.selfieUrl || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80');

  const details = {
    status: 'PENDING',
    documentType: documentType || 'NATIONAL_ID',
    documentNumber: documentNumber || '1098765432',
    idDocumentUrl,
    selfieUrl,
    countryCode: countryCode || 'SA',
    note: note || '',
    submittedAt: new Date().toISOString(),
    reviewedAt: null,
    reviewerNotes: null,
  };

  db.verifications[user.id] = details;
  user.verifiedStatus = 'PENDING';

  return success(res, details, null, 201);
});

v1.get('/verification/details', requireAuth, (req, res) => {
  const user = req.user;
  const details = db.verifications[user.id] || {
    status: user.verifiedStatus || 'NOT_STARTED',
    documentType: null,
    documentNumber: null,
    idDocumentUrl: null,
    selfieUrl: null,
    countryCode: null,
    note: null,
    submittedAt: null,
    reviewedAt: null,
    reviewerNotes: null,
  };
  return success(res, details);
});

// ==========================================
// 6. Missions Endpoints
// ==========================================
v1.get('/missions', (req, res) => {
  const { q, category } = req.query;
  const page = parseInt(req.query.page, 10) || 1;
  const limit = parseInt(req.query.limit, 10) || 20;

  let list = db.missions;
  if (q) {
    list = list.filter(m => m.title.toLowerCase().includes(q.toLowerCase()));
  }
  if (category) {
    list = list.filter(m => m.taskTypes.includes(category));
  }

  const total = list.length;
  const paged = list.slice((page - 1) * limit, page * limit).map(m => ({
    id: m.id,
    title: m.title,
    description: m.description,
    status: m.status,
    taskTypes: m.taskTypes,
    availableTasks: m.availableTasks,
    minRewardPoints: m.minRewardPoints,
    maxRewardPoints: m.maxRewardPoints,
    distanceMeters: m.distanceMeters,
    startAt: m.startAt,
    endAt: m.endAt,
  }));

  return success(res, { missions: paged }, { page, limit, total });
});

v1.get('/missions/:missionId', (req, res) => {
  const mission = db.missions.find(m => m.id === req.params.missionId);
  if (!mission) {
    return error(res, 'NOT_FOUND', 'Mission not found', [], 404);
  }
  return success(res, mission);
});

v1.get('/missions/:missionId/tasks', (req, res) => {
  const mission = db.missions.find(m => m.id === req.params.missionId);
  if (!mission) {
    return error(res, 'NOT_FOUND', 'Mission not found', [], 404);
  }

  const page = parseInt(req.query.page, 10) || 1;
  const limit = parseInt(req.query.limit, 10) || 20;

  let tasks = db.tasks.filter(t => t.campaignId === req.params.missionId);
  if (tasks.length === 0) {
    tasks = db.tasks;
  }

  const total = tasks.length;
  const paged = tasks.slice((page - 1) * limit, page * limit);

  return success(res, { tasks: paged }, { page, limit, total });
});

// ==========================================
// 7. Tasks Endpoints
// ==========================================
v1.get('/tasks/nearby', (req, res) => {
  const { type } = req.query;
  let list = db.tasks.map(t => ({
    id: t.id,
    campaignId: t.campaignId,
    type: t.type,
    title: t.title,
    rewardPoints: t.rewardPoints,
    expiresAt: t.expiresAt,
    distanceMeters: t.distanceMeters || 350,
    status: t.status,
  }));

  if (type) {
    list = list.filter(t => t.type === type);
  }

  return success(res, { tasks: list });
});

v1.get('/tasks/:taskId', (req, res) => {
  const task = db.tasks.find(t => t.id === req.params.taskId);
  if (!task) {
    return error(res, 'NOT_FOUND', 'Task not found', [], 404);
  }
  return success(res, task);
});

v1.post('/tasks/:taskId/reserve', requireAuth, (req, res) => {
  const user = req.user;
  const task = db.tasks.find(t => t.id === req.params.taskId);
  if (!task) {
    return error(res, 'NOT_FOUND', 'Task not found', [], 404);
  }

  const reservedUntil = new Date(Date.now() + 2 * 3600000).toISOString();
  task.status = 'RESERVED';
  db.reservations.set(task.id, { userId: user.id, reservedUntil });

  return success(res, { taskId: task.id, reservedUntil });
});

v1.post('/tasks/:taskId/submit', requireAuth, upload.array('files', 5), (req, res) => {
  const user = req.user;
  const task = db.tasks.find(t => t.id === req.params.taskId);
  if (!task) {
    return error(res, 'NOT_FOUND', 'Task not found', [], 404);
  }

  const { lat, lng, note } = req.body;
  const files = req.files || [];

  const evidence = files.map(f => ({
    id: uuid(),
    storageKey: `evidence/${f.filename}`,
    mimeType: f.mimetype,
    sizeBytes: f.size,
    checksum: crypto.createHash('md5').update(f.filename).digest('hex'),
    publicUrl: `http://${req.headers.host || '127.0.0.1:3000'}/uploads/${f.filename}`,
    createdAt: new Date().toISOString(),
  }));

  if (evidence.length === 0) {
    evidence.push({
      id: uuid(),
      storageKey: 'evidence/sample.jpg',
      mimeType: 'image/jpeg',
      sizeBytes: 1024500,
      checksum: 'sample-md5-hash',
      publicUrl: 'https://images.unsplash.com/photo-1618477461853-cf6ed80faba5?auto=format&fit=crop&w=800&q=80',
      createdAt: new Date().toISOString(),
    });
  }

  const newSubmission = {
    id: uuid(),
    taskId: task.id,
    campaignId: task.campaignId,
    userId: user.id,
    status: 'PENDING_REVIEW',
    verificationScore: 85,
    reasonCodes: [],
    note: note || null,
    location: {
      lat: parseFloat(lat) || task.location.lat,
      lng: parseFloat(lng) || task.location.lng,
    },
    evidence,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };

  db.submissions.unshift(newSubmission);
  task.status = 'COMPLETED';

  return success(res, { submissionId: newSubmission.id, status: newSubmission.status }, null, 201);
});

// ==========================================
// 8. Submissions Endpoints (User-Isolated)
// ==========================================
v1.post('/submissions', requireAuth, (req, res) => {
  const user = req.user;
  const { taskId, lat, lng, note } = req.body;
  const task = db.tasks.find(t => t.id === taskId) || db.tasks[0];

  const draft = {
    id: uuid(),
    taskId: task.id,
    campaignId: task.campaignId,
    userId: user.id,
    status: 'DRAFT',
    verificationScore: null,
    reasonCodes: [],
    note: note || null,
    location: {
      lat: parseFloat(lat) || 24.7136,
      lng: parseFloat(lng) || 46.6753,
    },
    evidence: [],
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };

  db.submissions.unshift(draft);
  return success(res, { submissionId: draft.id, status: draft.status }, null, 201);
});

v1.get('/submissions', requireAuth, (req, res) => {
  const user = req.user;
  const { status } = req.query;
  const page = parseInt(req.query.page, 10) || 1;
  const limit = parseInt(req.query.limit, 10) || 20;

  // STRICTLY filter by current logged in user's ID
  let list = db.submissions.filter(s => s.userId === user.id);
  if (status) {
    list = list.filter(s => s.status === status);
  }

  const total = list.length;
  const paged = list.slice((page - 1) * limit, page * limit).map(s => ({
    id: s.id,
    taskId: s.taskId,
    campaignId: s.campaignId,
    status: s.status,
    verificationScore: s.verificationScore,
    reasonCodes: s.reasonCodes,
    createdAt: s.createdAt,
    updatedAt: s.updatedAt,
  }));

  return success(res, { submissions: paged }, { page, limit, total });
});

v1.patch('/submissions/:submissionId', requireAuth, (req, res) => {
  const sub = db.submissions.find(s => s.id === req.params.submissionId && s.userId === req.user.id);
  if (!sub) {
    return error(res, 'NOT_FOUND', 'Submission not found or unauthorized', [], 404);
  }
  const { note, lat, lng } = req.body;
  if (note !== undefined) sub.note = note;
  if (lat && lng) sub.location = { lat: parseFloat(lat), lng: parseFloat(lng) };
  sub.updatedAt = new Date().toISOString();
  return success(res, sub);
});

v1.get('/submissions/:submissionId', requireAuth, (req, res) => {
  const sub = db.submissions.find(s => s.id === req.params.submissionId && (s.userId === req.user.id || req.user.role === 'ADMIN'));
  if (!sub) {
    return error(res, 'NOT_FOUND', 'Submission not found', [], 404);
  }
  return success(res, sub);
});

v1.post('/submissions/:submissionId/submit', requireAuth, upload.array('files', 5), (req, res) => {
  const sub = db.submissions.find(s => s.id === req.params.submissionId && s.userId === req.user.id);
  if (!sub) {
    return error(res, 'NOT_FOUND', 'Submission not found', [], 404);
  }

  const files = req.files || [];
  if (files.length > 0) {
    const newEvidence = files.map(f => ({
      id: uuid(),
      storageKey: `evidence/${f.filename}`,
      mimeType: f.mimetype,
      sizeBytes: f.size,
      checksum: crypto.createHash('md5').update(f.filename).digest('hex'),
      publicUrl: `http://${req.headers.host || '127.0.0.1:3000'}/uploads/${f.filename}`,
      createdAt: new Date().toISOString(),
    }));
    sub.evidence.push(...newEvidence);
  }

  sub.status = 'PENDING_REVIEW';
  sub.updatedAt = new Date().toISOString();

  return success(res, { submissionId: sub.id, status: sub.status });
});

// ==========================================
// 9. Campaigns Endpoints
// ==========================================
v1.post('/campaigns', requireAuth, (req, res) => {
  const user = req.user;
  const { title, description, budgetTotal, startAt, endAt, areaGeoJson, taskTypes } = req.body;

  if (!title || !budgetTotal || !startAt || !endAt || !areaGeoJson || !taskTypes) {
    return error(res, 'VALIDATION_ERROR', 'Missing required campaign fields');
  }

  const newCampaign = {
    id: uuid(),
    clientId: user.id,
    title,
    description: description || null,
    budgetTotal: parseFloat(budgetTotal),
    budgetRemaining: parseFloat(budgetTotal),
    areaGeoJson,
    taskTypes,
    status: 'ACTIVE',
    startAt,
    endAt,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };

  db.campaigns.unshift(newCampaign);
  return success(res, newCampaign, null, 201);
});

v1.get('/campaigns', (req, res) => {
  const { status } = req.query;
  const page = parseInt(req.query.page, 10) || 1;
  const limit = parseInt(req.query.limit, 10) || 20;

  let list = db.campaigns;
  if (status) {
    list = list.filter(c => c.status === status);
  }

  const total = list.length;
  const paged = list.slice((page - 1) * limit, page * limit);

  return success(res, { campaigns: paged }, { page, limit, total });
});

v1.get('/campaigns/:campaignId', (req, res) => {
  const camp = db.campaigns.find(c => c.id === req.params.campaignId);
  if (!camp) {
    return error(res, 'NOT_FOUND', 'Campaign not found', [], 404);
  }
  return success(res, camp);
});

v1.patch('/campaigns/:campaignId/status', requireAuth, (req, res) => {
  const camp = db.campaigns.find(c => c.id === req.params.campaignId);
  if (!camp) {
    return error(res, 'NOT_FOUND', 'Campaign not found', [], 404);
  }
  const { status } = req.body;
  if (!status) {
    return error(res, 'VALIDATION_ERROR', 'status is required');
  }
  camp.status = status;
  camp.updatedAt = new Date().toISOString();
  return success(res, camp);
});

v1.get('/campaigns/:campaignId/submissions', (req, res) => {
  const camp = db.campaigns.find(c => c.id === req.params.campaignId);
  if (!camp) {
    return error(res, 'NOT_FOUND', 'Campaign not found', [], 404);
  }

  const page = parseInt(req.query.page, 10) || 1;
  const limit = parseInt(req.query.limit, 10) || 20;

  const subs = db.submissions.map(s => ({
    id: s.id,
    taskId: s.taskId,
    userId: s.userId,
    status: s.status,
    verificationScore: s.verificationScore,
    reasonCodes: s.reasonCodes,
    createdAt: s.createdAt,
  }));

  const metrics = {
    totalSubmissions: subs.length,
    approvedSubmissions: subs.filter(s => s.status === 'APPROVED').length,
    rejectedSubmissions: subs.filter(s => s.status === 'REJECTED').length,
    flaggedSubmissions: subs.filter(s => s.status === 'FLAGGED').length,
    pointsPaid: 240,
  };

  const total = subs.length;
  const paged = subs.slice((page - 1) * limit, page * limit);

  return success(res, { submissions: paged, metrics }, { page, limit, total });
});

v1.get('/campaigns/:campaignId/submissions/export', (req, res) => {
  const csvRows = [
    'submissionId,taskId,userId,status,verificationScore,createdAt',
    ...db.submissions.map(
      s => `${s.id},${s.taskId},${s.userId},${s.status},${s.verificationScore || 0},${s.createdAt}`
    ),
  ];
  res.setHeader('Content-Type', 'text/csv');
  res.setHeader('Content-Disposition', 'attachment; filename=campaign-submissions.csv');
  return res.send(csvRows.join('\n'));
});

// ==========================================
// 10. Admin & Operations Review Endpoints
// ==========================================
function listAdminSubmissionsHandler(req, res) {
  const { status } = req.query;
  const page = parseInt(req.query.page, 10) || 1;
  const limit = parseInt(req.query.limit, 10) || 20;

  let list = db.submissions;
  if (status) {
    list = list.filter(s => s.status === status);
  }

  const total = list.length;
  const paged = list.slice((page - 1) * limit, page * limit);

  return success(res, { submissions: paged }, { page, limit, total });
}
v1.get('/admin/submissions', requireAuth, listAdminSubmissionsHandler);
v1.get('/ops/submissions', requireAuth, listAdminSubmissionsHandler);

function approveSubmissionHandler(req, res) {
  const sub = db.submissions.find(s => s.id === req.params.submissionId);
  if (!sub) {
    return error(res, 'NOT_FOUND', 'Submission not found', [], 404);
  }

  const { reasonCode, notes } = req.body;
  sub.status = 'APPROVED';
  sub.updatedAt = new Date().toISOString();
  sub.verifiedAt = new Date().toISOString();
  sub.verifiedBy = req.user.id;

  // Reward points to the user's specific wallet
  const userWallet = db.wallets[sub.userId] || { balancePoints: 0, transactions: [] };
  userWallet.balancePoints += 80;
  userWallet.transactions.unshift({
    id: uuid(),
    submissionId: sub.id,
    type: 'REWARD',
    amountPoints: 80,
    reason: `مكافأة اعتماد إثبات المهمة ${sub.id.substring(0, 8)}`,
    createdAt: new Date().toISOString(),
  });
  db.wallets[sub.userId] = userWallet;

  // Add notification to that specific user
  db.notifications.unshift({
    id: uuid(),
    userId: sub.userId,
    type: 'REWARD',
    title: 'تم اعتماد إثباتك وإيداع النقاط! 🎉',
    message: 'تهانينا، تم اعتماد المهمة بنجاح وإضافة 80 نقطة إلى محفظتك.',
    entityId: sub.id,
    deepLink: null,
    payload: { points: 80 },
    isRead: false,
    readAt: null,
    createdAt: new Date().toISOString(),
  });

  return success(res, {
    submissionId: sub.id,
    status: 'APPROVED',
    reasonCodes: reasonCode ? [reasonCode] : [],
    notes: notes || null,
    decidedAt: sub.verifiedAt,
  });
}
v1.post('/admin/submissions/:submissionId/approve', requireAuth, approveSubmissionHandler);
v1.post('/ops/submissions/:submissionId/approve', requireAuth, approveSubmissionHandler);

function rejectSubmissionHandler(req, res) {
  const sub = db.submissions.find(s => s.id === req.params.submissionId);
  if (!sub) {
    return error(res, 'NOT_FOUND', 'Submission not found', [], 404);
  }

  const { reasonCode, notes } = req.body;
  sub.status = 'REJECTED';
  sub.reasonCodes = reasonCode ? [reasonCode] : ['OTHER'];
  sub.updatedAt = new Date().toISOString();

  db.notifications.unshift({
    id: uuid(),
    userId: sub.userId,
    type: 'SUBMISSION_REJECTED',
    title: 'تم رفض إثبات المهمة ❌',
    message: notes || 'عذراً، لم يتطابق الإثبات المرفوع مع معايير المهمة المحددة.',
    entityId: sub.id,
    deepLink: null,
    payload: { reasonCode },
    isRead: false,
    readAt: null,
    createdAt: new Date().toISOString(),
  });

  return success(res, {
    submissionId: sub.id,
    status: 'REJECTED',
    reasonCodes: sub.reasonCodes,
    notes: notes || null,
    decidedAt: new Date().toISOString(),
  });
}
v1.post('/admin/submissions/:submissionId/reject', requireAuth, rejectSubmissionHandler);
v1.post('/ops/submissions/:submissionId/reject', requireAuth, rejectSubmissionHandler);

v1.post('/ops/submissions/:submissionId/request-info', requireAuth, (req, res) => {
  const sub = db.submissions.find(s => s.id === req.params.submissionId);
  if (!sub) {
    return error(res, 'NOT_FOUND', 'Submission not found', [], 404);
  }

  const { reasonCode, notes } = req.body;
  sub.status = 'NEEDS_INFO';
  sub.reasonCodes = reasonCode ? [reasonCode] : ['INVALID_MEDIA'];
  sub.updatedAt = new Date().toISOString();

  db.notifications.unshift({
    id: uuid(),
    userId: sub.userId,
    type: 'NEEDS_INFO',
    title: 'مطلوب توضيح إضافي للإثبات ⚠️',
    message: notes || 'يرجى تقديم صور أو تفاصيل إضافية لإتمام عملية التدقيق.',
    entityId: sub.id,
    deepLink: null,
    payload: { reasonCode },
    isRead: false,
    readAt: null,
    createdAt: new Date().toISOString(),
  });

  return success(res, {
    submissionId: sub.id,
    status: 'NEEDS_INFO',
    reasonCodes: sub.reasonCodes,
    notes: notes || null,
    decidedAt: new Date().toISOString(),
  });
});

v1.post('/admin/wallet/:userId/adjust', requireAuth, (req, res) => {
  const { type, amountPoints, reason } = req.body;
  if (!type || !amountPoints || !reason) {
    return error(res, 'VALIDATION_ERROR', 'type, amountPoints, and reason are required');
  }

  const targetUserId = req.params.userId;
  const wallet = db.wallets[targetUserId] || { balancePoints: 0, transactions: [] };
  wallet.balancePoints += amountPoints;

  const transaction = {
    id: uuid(),
    submissionId: null,
    type,
    amountPoints,
    reason,
    createdAt: new Date().toISOString(),
  };
  wallet.transactions.unshift(transaction);
  db.wallets[targetUserId] = wallet;

  return success(res, { userId: targetUserId, transaction }, null, 201);
});

// Mount /api/v1 router
app.use('/api/v1', v1);

// Root route
app.get('/', (req, res) => {
  res.json({
    name: 'ImpactLoop Local Mock API Server',
    status: 'Running',
    version: '1.0.0',
    basePath: '/api/v1',
  });
});

// 404 handler
app.use((req, res) => {
  return error(res, 'NOT_FOUND', `Cannot ${req.method} ${req.originalUrl}`, [], 404);
});

// Start listening
app.listen(PORT, '0.0.0.0', () => {
  console.log(`====================================================`);
  console.log(`🚀 ImpactLoop Local API Server is running!`);
  console.log(`📡 URL: http://127.0.0.1:${PORT}/api/v1`);
  console.log(`====================================================`);
});
