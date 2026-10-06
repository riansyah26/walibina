import React, { useState, useEffect } from 'react';
import { 
    Users, 
    BookOpen, 
    Award, 
    Star, 
    Calendar, 
    FileText, 
    PieChart as PieChartIcon,
    Plus,
    Save,
    Trash2,
    CheckCircle,
    Clock,
    User,
    ChevronDown,
    Printer,
    Settings,
    Edit2
} from 'lucide-react';
import { 
    BarChart, 
    Bar, 
    XAxis, 
    YAxis, 
    CartesianGrid, 
    Tooltip as RechartsTooltip, 
    Legend, 
    ResponsiveContainer, 
    PieChart, 
    Pie, 
    Cell 
} from 'recharts';

const ASPEK_PEMBINAAN = {
    kompetensi: { id: 'kompetensi', label: 'Kompetensi', icon: Award, color: '#3b82f6', bgColor: 'bg-blue-100', text: 'text-blue-700' },
    akademik: { id: 'akademik', label: 'Akademik', icon: BookOpen, color: '#10b981', bgColor: 'bg-green-100', text: 'text-green-700' },
    karakter: { id: 'karakter', label: 'Karakter', icon: Star, color: '#f59e0b', bgColor: 'bg-yellow-100', text: 'text-yellow-700' },
    keterampilan: { id: 'keterampilan', label: 'Keterampilan', icon: Settings, color: '#8b5cf6', bgColor: 'bg-purple-100', text: 'text-purple-700' }
};

const INDIKATOR_PRESET = {
    kompetensi: ['Kepemimpinan', 'Kerja Sama Tim', 'Pemecahan Masalah', 'Komunikasi Efektif', 'Berpikir Kritis'],
    akademik: ['Peningkatan Nilai Ulangan', 'Kedisiplinan Mengerjakan Tugas', 'Keaktifan Bertanya di Kelas', 'Kemampuan Membaca/Literasi', 'Penguasaan Materi Dasar'],
    karakter: ['Kedisiplinan Waktu (Hadir)', 'Ibadah Yaumiyah', 'Sopan Santun & Etika', 'Kejujuran', 'Tanggung Jawab'],
    keterampilan: ['Keterampilan IT Dasar', 'Public Speaking', 'Karya Seni/Prakarya', 'Olahraga', 'Kecakapan Hidup (Pramuka/UKS)']
};

const INITIAL_STUDENTS = [
    { id: 'S001', name: 'Ahmad Fauzi', nis: '2324001' },
    { id: 'S002', name: 'Budi Santoso', nis: '2324002' },
    { id: 'S003', name: 'Citra Kirana', nis: '2324003' },
    { id: 'S004', name: 'Dewi Lestari', nis: '2324004' },
    { id: 'S005', name: 'Eko Prasetyo', nis: '2324005' },
];

const TRIWULAN = [
    { id: 'Q1', label: 'Triwulan 1 (Jan-Mar)', months: [0, 1, 2] },
    { id: 'Q2', label: 'Triwulan 2 (Apr-Jun)', months: [3, 4, 5] },
    { id: 'Q3', label: 'Triwulan 3 (Jul-Sep)', months: [6, 7, 8] },
    { id: 'Q4', label: 'Triwulan 4 (Okt-Des)', months: [9, 10, 11] }
];

export default function App() {
    const [activeTab, setActiveTab] = useState('dashboard');
    const [coachingRecords, setCoachingRecords] = useState([]);
    
    // Dynamic Students State
    const [studentsList, setStudentsList] = useState(INITIAL_STUDENTS);
    
    // Teacher Profile State
    const [teacherProfile, setTeacherProfile] = useState({
        name: 'Muhammad Riansyah, M.Pd.',
        nip: '1431069',
        kelas: 'VII D'
    });

    // Form State for new student
    const [newStudent, setNewStudent] = useState({ name: '', nis: '' });
    
    // Form State for new coaching record
    const [formData, setFormData] = useState({
        studentId: '',
        date: new Date().toISOString().split('T')[0],
        aspek: 'kompetensi',
        indikator: '',
        target: '',
        hasil: '',
        tindakLanjut: ''
    });

    // Date filtering states
    const [selectedWeekStart, setSelectedWeekStart] = useState(getMonday(new Date()).toISOString().split('T')[0]);
    const [selectedTriwulan, setSelectedTriwulan] = useState(() => {
        const currentMonth = new Date().getMonth();
        return TRIWULAN.find(t => t.months.includes(currentMonth)).id;
    });

    function getMonday(d) {
        d = new Date(d);
        var day = d.getDay(),
            diff = d.getDate() - day + (day === 0 ? -6 : 1); // adjust when day is sunday
        return new Date(d.setDate(diff));
    }

    const handleInputChange = (e) => {
        const { name, value } = e.target;
        setFormData(prev => ({ ...prev, [name]: value }));
        
        // Reset indikator if aspek changes
        if (name === 'aspek') {
            setFormData(prev => ({ ...prev, indikator: '' }));
        }
    };

    const handleAddStudent = (e) => {
        e.preventDefault();
        if (!newStudent.name || !newStudent.nis) return;
        
        const student = {
            id: `S${Date.now()}`,
            name: newStudent.name,
            nis: newStudent.nis
        };
        
        setStudentsList(prev => [...prev, student]);
        setNewStudent({ name: '', nis: '' });
    };

    const handleDeleteStudent = (id) => {
        if (window.confirm('Yakin ingin menghapus siswa ini? Data pembinaan terkait mungkin akan kehilangan referensi nama.')) {
            setStudentsList(prev => prev.filter(s => s.id !== id));
        }
    };

    const handleProfileChange = (e) => {
        const { name, value } = e.target;
        setTeacherProfile(prev => ({ ...prev, [name]: value }));
    };

    const handleAddRecord = (e) => {
        e.preventDefault();
        const newRecord = {
            id: Date.now().toString(),
            ...formData,
            timestamp: new Date().toISOString()
        };
        setCoachingRecords([newRecord, ...coachingRecords]);
        
        // Reset form but keep date and aspek
        setFormData(prev => ({
            ...prev,
            studentId: '',
            indikator: '',
            target: '',
            hasil: '',
            tindakLanjut: ''
        }));
        
        alert('Data pembinaan berhasil disimpan!');
    };

    const deleteRecord = (id) => {
        if(window.confirm('Hapus catatan pembinaan ini?')) {
            setCoachingRecords(coachingRecords.filter(r => r.id !== id));
        }
    };

    const renderDashboard = () => {
        // Prepare chart data
        const aspekCount = { kompetensi: 0, akademik: 0, karakter: 0, keterampilan: 0 };
        coachingRecords.forEach(r => {
            if (aspekCount[r.aspek] !== undefined) aspekCount[r.aspek]++;
        });

        const barChartData = Object.keys(ASPEK_PEMBINAAN).map(key => ({
            name: ASPEK_PEMBINAAN[key].label,
            jumlah: aspekCount[key],
            fill: ASPEK_PEMBINAAN[key].color
        }));

        const pieChartData = barChartData.filter(d => d.jumlah > 0);
        const COLORS = pieChartData.map(d => d.fill);

        return (
            <div className="space-y-6 animate-fadeIn">
                <div className="flex justify-between items-end">
                    <div>
                        <h2 className="text-2xl font-bold text-gray-800">Dashboard Pembinaan</h2>
                        <p className="text-gray-500 text-sm mt-1">Ringkasan aktivitas Guru Wali kelas {teacherProfile.kelas}</p>
                    </div>
                </div>

                {/* Stats Cards */}
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                    {Object.values(ASPEK_PEMBINAAN).map(aspek => {
                        const Icon = aspek.icon;
                        const count = aspekCount[aspek.id];
                        return (
                            <div key={aspek.id} className="bg-white p-5 rounded-xl shadow-sm border border-gray-100 flex items-center space-x-4">
                                <div className={`p-3 rounded-lg ${aspek.bgColor}`}>
                                    <Icon size={24} className={aspek.text} />
                                </div>
                                <div>
                                    <p className="text-sm font-medium text-gray-500">{aspek.label}</p>
                                    <h3 className="text-2xl font-bold text-gray-800">{count}</h3>
                                </div>
                            </div>
                        );
                    })}
                </div>

                {/* Charts */}
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                    <div className="bg-white p-5 rounded-xl shadow-sm border border-gray-100">
                        <h3 className="text-lg font-semibold text-gray-700 mb-4">Distribusi Aspek Pembinaan</h3>
                        <div className="h-64">
                            {coachingRecords.length > 0 ? (
                                <ResponsiveContainer width="100%" height="100%">
                                    <BarChart data={barChartData} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                                        <CartesianGrid strokeDasharray="3 3" vertical={false} />
                                        <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{fontSize: 12}} />
                                        <YAxis axisLine={false} tickLine={false} tick={{fontSize: 12}} allowDecimals={false} />
                                        <RechartsTooltip cursor={{fill: '#f3f4f6'}} contentStyle={{borderRadius: '8px', border: 'none', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)'}} />
                                        <Bar dataKey="jumlah" radius={[4, 4, 0, 0]} maxBarSize={50}>
                                            {barChartData.map((entry, index) => (
                                                <Cell key={`cell-${index}`} fill={entry.fill} />
                                            ))}
                                        </Bar>
                                    </BarChart>
                                </ResponsiveContainer>
                            ) : (
                                <div className="h-full flex items-center justify-center text-gray-400 text-sm">Belum ada data pembinaan</div>
                            )}
                        </div>
                    </div>

                    <div className="bg-white p-5 rounded-xl shadow-sm border border-gray-100">
                        <h3 className="text-lg font-semibold text-gray-700 mb-4">Persentase Fokus</h3>
                        <div className="h-64">
                            {pieChartData.length > 0 ? (
                                <ResponsiveContainer width="100%" height="100%">
                                    <PieChart>
                                        <Pie
                                            data={pieChartData}
                                            cx="50%"
                                            cy="50%"
                                            innerRadius={60}
                                            outerRadius={80}
                                            paddingAngle={5}
                                            dataKey="jumlah"
                                        >
                                            {pieChartData.map((entry, index) => (
                                                <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                                            ))}
                                        </Pie>
                                        <RechartsTooltip contentStyle={{borderRadius: '8px', border: 'none', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)'}} />
                                        <Legend verticalAlign="bottom" height={36} iconType="circle" wrapperStyle={{fontSize: '12px'}} />
                                    </PieChart>
                                </ResponsiveContainer>
                            ) : (
                                <div className="h-full flex items-center justify-center text-gray-400 text-sm">Belum ada data pembinaan</div>
                            )}
                        </div>
                    </div>
                </div>

                {/* Recent Activities */}
                <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                    <div className="p-5 border-b border-gray-100 bg-gray-50 flex justify-between items-center">
                        <h3 className="text-lg font-semibold text-gray-700">Aktivitas Pembinaan Terakhir</h3>
                        <button onClick={() => setActiveTab('input')} className="text-sm text-green-600 hover:text-green-800 font-medium">Lihat Semua</button>
                    </div>
                    <div className="divide-y divide-gray-100">
                        {coachingRecords.length === 0 ? (
                            <div className="p-8 text-center text-gray-500">Belum ada catatan pembinaan.</div>
                        ) : (
                            coachingRecords.slice(0, 5).map(record => {
                                const student = studentsList.find(s => s.id === record.studentId);
                                const aspek = Object.values(ASPEK_PEMBINAAN).find(a => a.id === record.aspek);
                                const AspekIcon = aspek?.icon || FileText;
                                
                                return (
                                    <div key={record.id} className="p-5 hover:bg-gray-50 transition-colors flex items-start space-x-4">
                                        <div className={`p-2 rounded-lg ${aspek?.bgColor || 'bg-gray-100'} mt-1`}>
                                            <AspekIcon size={20} className={aspek?.text || 'text-gray-500'} />
                                        </div>
                                        <div className="flex-1 min-w-0">
                                            <div className="flex items-center justify-between">
                                                <p className="text-sm font-medium text-gray-900 truncate">{student?.name || 'Siswa Dihapus'}</p>
                                                <p className="text-xs text-gray-500">{new Date(record.date).toLocaleDateString('id-ID')}</p>
                                            </div>
                                            <p className="text-sm text-gray-600 mt-0.5"><span className="font-medium">{aspek?.label}</span>: {record.indikator}</p>
                                            <p className="text-sm text-gray-500 mt-1 truncate">Hasil: {record.hasil}</p>
                                        </div>
                                    </div>
                                )
                            })
                        )}
                    </div>
                </div>
            </div>
        );
    };

    const renderInputForm = () => {
        return (
            <div className="space-y-6 animate-fadeIn">
                <h2 className="text-2xl font-bold text-gray-800 border-b pb-2">Catat Data Pembinaan</h2>
                
                <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                    {/* Form Section */}
                    <form onSubmit={handleAddRecord} className="lg:col-span-1 bg-white p-6 rounded-xl shadow-sm border border-gray-100 space-y-4">
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Tanggal</label>
                            <input 
                                type="date" 
                                name="date"
                                value={formData.date}
                                onChange={handleInputChange}
                                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 outline-none transition-shadow"
                                required
                            />
                        </div>

                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Siswa Binaan</label>
                            <select 
                                name="studentId"
                                value={formData.studentId}
                                onChange={handleInputChange}
                                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 outline-none"
                                required
                            >
                                <option value="">-- Pilih Siswa --</option>
                                {studentsList.map(s => (
                                    <option key={s.id} value={s.id}>{s.name} ({s.nis})</option>
                                ))}
                            </select>
                        </div>

                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Aspek Pembinaan</label>
                            <div className="grid grid-cols-2 gap-2">
                                {Object.values(ASPEK_PEMBINAAN).map(aspek => (
                                    <label 
                                        key={aspek.id} 
                                        className={`flex items-center p-2 border rounded-lg cursor-pointer transition-colors ${formData.aspek === aspek.id ? `border-${aspek.color.replace('#','')} ${aspek.bgColor} ring-1 ring-${aspek.color.replace('#','')}` : 'border-gray-200 hover:bg-gray-50'}`}
                                    >
                                        <input 
                                            type="radio" 
                                            name="aspek" 
                                            value={aspek.id}
                                            checked={formData.aspek === aspek.id}
                                            onChange={handleInputChange}
                                            className="sr-only"
                                        />
                                        <aspek.icon size={16} className={`mr-2 ${formData.aspek === aspek.id ? aspek.text : 'text-gray-400'}`} />
                                        <span className={`text-xs font-medium ${formData.aspek === aspek.id ? 'text-gray-900' : 'text-gray-600'}`}>{aspek.label}</span>
                                    </label>
                                ))}
                            </div>
                        </div>

                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Indikator / Topik</label>
                            <select 
                                name="indikator"
                                value={formData.indikator}
                                onChange={handleInputChange}
                                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 outline-none"
                                required
                            >
                                <option value="">-- Pilih Indikator --</option>
                                {INDIKATOR_PRESET[formData.aspek]?.map((ind, idx) => (
                                    <option key={idx} value={ind}>{ind}</option>
                                ))}
                                <option value="Lainnya">Lainnya...</option>
                            </select>
                            {formData.indikator === 'Lainnya' && (
                                <input 
                                    type="text"
                                    placeholder="Tulis indikator spesifik..."
                                    className="w-full mt-2 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 text-sm"
                                    onChange={(e) => setFormData(prev => ({...prev, indikator: e.target.value}))}
                                />
                            )}
                        </div>

                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Target Pembinaan</label>
                            <textarea 
                                name="target"
                                value={formData.target}
                                onChange={handleInputChange}
                                rows="2"
                                placeholder="Cth: Siswa dapat disiplin hadir tepat waktu."
                                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 outline-none resize-none text-sm"
                                required
                            ></textarea>
                        </div>

                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Hasil Observasi/Diskusi</label>
                            <textarea 
                                name="hasil"
                                value={formData.hasil}
                                onChange={handleInputChange}
                                rows="2"
                                placeholder="Cth: Siswa menyadari kesalahannya karena bangun kesiangan."
                                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 outline-none resize-none text-sm"
                                required
                            ></textarea>
                        </div>

                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Tindak Lanjut</label>
                            <textarea 
                                name="tindakLanjut"
                                value={formData.tindakLanjut}
                                onChange={handleInputChange}
                                rows="2"
                                placeholder="Cth: Memantau presensi selama 1 minggu ke depan."
                                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 outline-none resize-none text-sm"
                                required
                            ></textarea>
                        </div>

                        <button 
                            type="submit"
                            className="w-full py-2.5 bg-green-600 hover:bg-green-700 text-white font-medium rounded-lg flex justify-center items-center transition-colors shadow-sm"
                        >
                            <Save size={18} className="mr-2" /> Simpan Catatan
                        </button>
                    </form>

                    {/* History Section */}
                    <div className="lg:col-span-2 bg-white rounded-xl shadow-sm border border-gray-100 flex flex-col h-[calc(100vh-12rem)] min-h-[600px]">
                        <div className="p-5 border-b border-gray-100 bg-gray-50 rounded-t-xl flex justify-between items-center">
                            <h3 className="text-lg font-semibold text-gray-700">Riwayat Catatan</h3>
                            <span className="bg-green-100 text-green-800 text-xs font-semibold px-2.5 py-0.5 rounded-full">Total: {coachingRecords.length}</span>
                        </div>
                        <div className="flex-1 overflow-y-auto p-2">
                            {coachingRecords.length === 0 ? (
                                <div className="flex flex-col items-center justify-center h-full text-gray-400">
                                    <FileText size={48} className="mb-4 opacity-20" />
                                    <p>Belum ada catatan pembinaan yang ditambahkan.</p>
                                </div>
                            ) : (
                                coachingRecords.map(record => {
                                    const student = studentsList.find(s => s.id === record.studentId);
                                    const aspek = Object.values(ASPEK_PEMBINAAN).find(a => a.id === record.aspek);
                                    
                                    return (
                                        <div key={record.id} className="m-2 p-4 border border-gray-100 rounded-lg hover:shadow-md transition-shadow bg-white relative group">
                                            <button 
                                                onClick={() => deleteRecord(record.id)}
                                                className="absolute top-4 right-4 text-gray-400 hover:text-red-500 opacity-0 group-hover:opacity-100 transition-opacity"
                                                title="Hapus Catatan"
                                            >
                                                <Trash2 size={16} />
                                            </button>
                                            <div className="flex items-center justify-between mb-3 border-b pb-2">
                                                <div className="flex items-center space-x-2">
                                                    <span className={`px-2.5 py-1 text-xs font-medium rounded-full ${aspek?.bgColor} ${aspek?.text} flex items-center`}>
                                                        {aspek?.icon && <aspek.icon size={12} className="mr-1" />}
                                                        {aspek?.label}
                                                    </span>
                                                    <span className="text-sm font-medium text-gray-800">{student?.name || 'Siswa Dihapus'}</span>
                                                </div>
                                                <div className="text-xs text-gray-500 flex items-center">
                                                    <Calendar size={12} className="mr-1" />
                                                    {new Date(record.date).toLocaleDateString('id-ID', { weekday: 'short', day: 'numeric', month: 'short', year: 'numeric' })}
                                                </div>
                                            </div>
                                            <div className="space-y-2 text-sm">
                                                <p><span className="font-medium text-gray-700">Indikator:</span> {record.indikator}</p>
                                                <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mt-2">
                                                    <div className="bg-gray-50 p-2 rounded border border-gray-100">
                                                        <span className="block text-xs font-semibold text-gray-500 mb-1">Target:</span>
                                                        <span className="text-gray-700">{record.target}</span>
                                                    </div>
                                                    <div className="bg-gray-50 p-2 rounded border border-gray-100">
                                                        <span className="block text-xs font-semibold text-gray-500 mb-1">Hasil:</span>
                                                        <span className="text-gray-700">{record.hasil}</span>
                                                    </div>
                                                    <div className="bg-blue-50 p-2 rounded border border-blue-100">
                                                        <span className="block text-xs font-semibold text-blue-600 mb-1">Tindak Lanjut:</span>
                                                        <span className="text-gray-700">{record.tindakLanjut}</span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    )
                                })
                            )}
                        </div>
                    </div>
                </div>
            </div>
        );
    };

    const renderPengaturan = () => (
        <div className="space-y-6 animate-fadeIn">
            <h2 className="text-2xl font-bold text-gray-800 border-b pb-2">Pengaturan Data</h2>
            
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                {/* Teacher Profile */}
                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 h-fit">
                    <div className="flex items-center space-x-3 mb-4 pb-2 border-b">
                        <User className="text-green-600" size={24} />
                        <h3 className="text-lg font-semibold text-gray-700">Profil Guru Wali</h3>
                    </div>
                    <div className="space-y-4">
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Nama Lengkap & Gelar</label>
                            <input 
                                type="text" 
                                name="name"
                                value={teacherProfile.name}
                                onChange={handleProfileChange}
                                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 outline-none"
                            />
                        </div>
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">NIP/NBM</label>
                            <input 
                                type="text" 
                                name="nip"
                                value={teacherProfile.nip}
                                onChange={handleProfileChange}
                                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 outline-none"
                            />
                        </div>
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Wali Kelas</label>
                            <input 
                                type="text" 
                                name="kelas"
                                value={teacherProfile.kelas}
                                onChange={handleProfileChange}
                                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 outline-none"
                            />
                        </div>
                        <div className="bg-blue-50 p-3 rounded-lg flex items-start mt-4">
                            <Clock className="text-blue-500 mr-2 shrink-0 mt-0.5" size={16} />
                            <p className="text-xs text-blue-700">
                                Profil ini akan otomatis tercetak di bagian bawah (tanda tangan) pada dokumen RPP dan Laporan.
                            </p>
                        </div>
                    </div>
                </div>

                {/* Students List */}
                <div className="bg-white rounded-xl shadow-sm border border-gray-100 flex flex-col h-[calc(100vh-12rem)] min-h-[500px]">
                    <div className="p-5 border-b border-gray-100 bg-gray-50 rounded-t-xl flex justify-between items-center">
                        <div className="flex items-center space-x-3">
                            <Users className="text-green-600" size={24} />
                            <h3 className="text-lg font-semibold text-gray-700">Daftar Siswa Binaan</h3>
                        </div>
                        <span className="bg-green-100 text-green-800 text-xs font-semibold px-2.5 py-0.5 rounded-full">
                            Total: {studentsList.length}
                        </span>
                    </div>
                    
                    <div className="p-4 border-b border-gray-100">
                        <form onSubmit={handleAddStudent} className="flex space-x-2">
                            <input 
                                type="text" 
                                placeholder="NIS"
                                value={newStudent.nis}
                                onChange={(e) => setNewStudent({...newStudent, nis: e.target.value})}
                                className="w-1/3 px-3 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 outline-none"
                                required
                            />
                            <input 
                                type="text" 
                                placeholder="Nama Lengkap Siswa"
                                value={newStudent.name}
                                onChange={(e) => setNewStudent({...newStudent, name: e.target.value})}
                                className="flex-1 px-3 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 outline-none"
                                required
                            />
                            <button 
                                type="submit"
                                className="px-4 py-2 bg-gray-800 hover:bg-gray-900 text-white rounded-lg flex items-center transition-colors"
                            >
                                <Plus size={16} />
                            </button>
                        </form>
                    </div>

                    <div className="flex-1 overflow-y-auto p-4">
                        <ul className="divide-y divide-gray-100">
                            {studentsList.length === 0 ? (
                                <li className="text-center py-8 text-gray-500">Belum ada siswa terdaftar.</li>
                            ) : (
                                studentsList.map(student => (
                                    <li key={student.id} className="py-3 flex justify-between items-center hover:bg-gray-50 px-2 rounded-lg group">
                                        <div>
                                            <p className="font-medium text-gray-800">{student.name}</p>
                                            <p className="text-xs text-gray-500">NIS: {student.nis}</p>
                                        </div>
                                        <button 
                                            onClick={() => handleDeleteStudent(student.id)}
                                            className="text-gray-400 hover:text-red-500 opacity-0 group-hover:opacity-100 transition-opacity p-2"
                                            title="Hapus Siswa"
                                        >
                                            <Trash2 size={16} />
                                        </button>
                                    </li>
                                ))
                            )}
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    );

    const renderRencanaPekan = () => {
        // Calculate week end
        const weekStart = new Date(selectedWeekStart);
        const weekEnd = new Date(weekStart);
        weekEnd.setDate(weekEnd.getDate() + 6);

        const dateStr = `${weekStart.toLocaleDateString('id-ID', {day:'numeric', month:'short'})} - ${weekEnd.toLocaleDateString('id-ID', {day:'numeric', month:'short', year:'numeric'})}`;

        // Filter data
        const weeklyData = coachingRecords.filter(r => {
            const rDate = new Date(r.date);
            return rDate >= weekStart && rDate <= weekEnd;
        }).sort((a,b) => new Date(a.date) - new Date(b.date));

        return (
            <div className="space-y-6 animate-fadeIn">
                <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center space-y-4 sm:space-y-0 print:hidden">
                    <div className="flex items-center space-x-3">
                        <h2 className="text-2xl font-bold text-gray-800">RPP Guru Wali</h2>
                        <button onClick={() => window.print()} className="flex items-center px-3 py-1.5 bg-gray-800 text-white text-sm rounded hover:bg-gray-700 transition">
                            <Printer size={16} className="mr-2" /> Cetak PDF
                        </button>
                    </div>
                    
                    <div className="flex items-center space-x-3 bg-white p-2 rounded-lg shadow-sm border border-gray-200">
                        <Calendar size={18} className="text-gray-500" />
                        <span className="text-sm text-gray-600 font-medium">Pekan mulai:</span>
                        <input 
                            type="date" 
                            value={selectedWeekStart}
                            onChange={(e) => setSelectedWeekStart(getMonday(new Date(e.target.value)).toISOString().split('T')[0])}
                            className="text-sm outline-none bg-transparent font-semibold text-green-600 cursor-pointer"
                        />
                    </div>
                </div>

                <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-8 print:shadow-none print:border-none print:p-0">
                    {/* Header Document */}
                    <div className="border-b-2 border-gray-800 pb-4 mb-6 text-center">
                        <h1 className="text-xl font-bold uppercase">MAJELIS PENDIDIKAN DASAR DAN MENENGAH</h1>
                        <h2 className="text-2xl font-bold uppercase tracking-wide">SMP MUHAMMADIYAH 3 BANDAR LAMPUNG</h2>
                        <p className="text-xs mt-1 text-gray-700">Jl. Zainal Abidin Pagar Alam No. 14, Labuhan Ratu, Bandar Lampung</p>
                    </div>
                    
                    <div className="text-center mb-6">
                        <h3 className="text-lg font-bold uppercase decoration-solid underline">RENCANA PELAKSANAAN PEMBINAAN (RPP) WALI KELAS</h3>
                        <p className="text-sm mt-1">
                            Kelas: <strong>{teacherProfile.kelas}</strong> | Periode Pekan: <strong>{dateStr}</strong>
                        </p>
                    </div>

                    {/* Table Data */}
                    <div className="overflow-x-auto">
                        <table className="w-full text-sm border-collapse border border-gray-300">
                            <thead>
                                <tr className="bg-gray-100 text-gray-800">
                                    <th className="border border-gray-300 p-2 w-10 text-center">No</th>
                                    <th className="border border-gray-300 p-2 w-24 text-center">Hari/Tanggal</th>
                                    <th className="border border-gray-300 p-2 w-40 text-left">Nama Siswa</th>
                                    <th className="border border-gray-300 p-2 w-32 text-center">Aspek</th>
                                    <th className="border border-gray-300 p-2 text-left">Indikator & Target</th>
                                    <th className="border border-gray-300 p-2 text-left">Hasil Pembinaan</th>
                                    <th className="border border-gray-300 p-2 text-left">Tindak Lanjut</th>
                                </tr>
                            </thead>
                            <tbody>
                                {weeklyData.length === 0 ? (
                                    <tr>
                                        <td colSpan="7" className="border border-gray-300 p-8 text-center text-gray-500 italic">
                                            Tidak ada jadwal/catatan pembinaan pada pekan ini.
                                        </td>
                                    </tr>
                                ) : (
                                    weeklyData.map((record, index) => {
                                        const student = studentsList.find(s => s.id === record.studentId);
                                        const aspek = Object.values(ASPEK_PEMBINAAN).find(a => a.id === record.aspek);
                                        
                                        return (
                                            <tr key={record.id} className="hover:bg-gray-50">
                                                <td className="border border-gray-300 p-2 text-center">{index + 1}</td>
                                                <td className="border border-gray-300 p-2 text-center">
                                                    {new Date(record.date).toLocaleDateString('id-ID', {weekday:'short', day:'2-digit', month:'2-digit'})}
                                                </td>
                                                <td className="border border-gray-300 p-2 font-medium">{student?.name || '-'}</td>
                                                <td className="border border-gray-300 p-2 text-center">
                                                    <span className={`inline-block px-2 py-1 rounded text-xs font-semibold ${aspek?.bgColor} ${aspek?.text}`}>
                                                        {aspek?.label}
                                                    </span>
                                                </td>
                                                <td className="border border-gray-300 p-2">
                                                    <strong>{record.indikator}</strong><br/>
                                                    <span className="text-gray-600 text-xs">{record.target}</span>
                                                </td>
                                                <td className="border border-gray-300 p-2">{record.hasil}</td>
                                                <td className="border border-gray-300 p-2">{record.tindakLanjut}</td>
                                            </tr>
                                        )
                                    })
                                )}
                            </tbody>
                        </table>
                    </div>

                    {/* Signatures */}
                    <div className="mt-12 flex justify-between px-8">
                        <div className="text-center">
                            <p className="mb-16">Mengetahui,<br/>Kepala Sekolah</p>
                            <p className="font-bold underline">Drs. Nur Salim</p>
                            <p className="text-sm mt-1">NBM. -</p>
                        </div>
                        <div className="text-center">
                            <p className="mb-16">Bandar Lampung, {new Date().toLocaleDateString('id-ID', { day:'numeric', month:'long', year:'numeric'})}<br/>Guru Wali Kelas</p>
                            <p className="font-bold underline">{teacherProfile.name}</p>
                            <p className="text-sm mt-1">NBM/NIP. {teacherProfile.nip}</p>
                        </div>
                    </div>
                </div>
            </div>
        );
    };

    const renderLaporanTriwulan = () => {
        const qInfo = TRIWULAN.find(t => t.id === selectedTriwulan);
        
        // Filter records by selected quarter months
        const qRecords = coachingRecords.filter(r => {
            const m = new Date(r.date).getMonth();
            return qInfo.months.includes(m);
        });

        // Calculate statistics
        const stats = {
            kompetensi: 0, akademik: 0, karakter: 0, keterampilan: 0
        };
        const studentSet = new Set();

        qRecords.forEach(r => {
            if(stats[r.aspek] !== undefined) stats[r.aspek]++;
            studentSet.add(r.studentId);
        });

        const totalRecords = qRecords.length;
        const reportStats = {
            total: totalRecords,
            studentCount: studentSet.size,
            aspek: stats
        };

        return (
            <div className="space-y-6 animate-fadeIn">
                <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center space-y-4 sm:space-y-0 print:hidden">
                    <div className="flex items-center space-x-3">
                        <h2 className="text-2xl font-bold text-gray-800">Laporan 3 Bulanan</h2>
                        <button onClick={() => window.print()} className="flex items-center px-3 py-1.5 bg-gray-800 text-white text-sm rounded hover:bg-gray-700 transition">
                            <Printer size={16} className="mr-2" /> Cetak PDF
                        </button>
                    </div>
                    
                    <div className="flex items-center space-x-3 bg-white p-2 rounded-lg shadow-sm border border-gray-200">
                        <PieChartIcon size={18} className="text-gray-500" />
                        <select 
                            value={selectedTriwulan}
                            onChange={(e) => setSelectedTriwulan(e.target.value)}
                            className="text-sm outline-none bg-transparent font-semibold text-green-600 cursor-pointer"
                        >
                            {TRIWULAN.map(t => (
                                <option key={t.id} value={t.id}>{t.label}</option>
                            ))}
                        </select>
                    </div>
                </div>

                <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-8 print:shadow-none print:border-none print:p-0">
                    {/* Header Document */}
                    <div className="border-b-2 border-gray-800 pb-4 mb-6 text-center">
                        <h1 className="text-xl font-bold uppercase">MAJELIS PENDIDIKAN DASAR DAN MENENGAH</h1>
                        <h2 className="text-2xl font-bold uppercase tracking-wide">SMP MUHAMMADIYAH 3 BANDAR LAMPUNG</h2>
                        <p className="text-xs mt-1 text-gray-700">Jl. Zainal Abidin Pagar Alam No. 14, Labuhan Ratu, Bandar Lampung</p>
                    </div>

                    <div className="text-center mb-6">
                        <h3 className="text-lg font-bold uppercase decoration-solid underline">LAPORAN EVALUASI PEMBINAAN SISWA</h3>
                        <p className="text-sm mt-1">
                            Guru Wali: <strong>{teacherProfile.name}</strong> | Kelas: <strong>{teacherProfile.kelas}</strong> <br/>
                            Periode: <strong>{qInfo?.label} Tahun Ajaran 2026/2027</strong>
                        </p>
                    </div>

                    {/* Ringkasan Eksekutif */}
                    <div className="mb-8">
                        <h4 className="font-bold text-gray-800 border-b border-gray-300 pb-2 mb-4">A. Ringkasan Eksekutif</h4>
                        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
                            <div className="border border-gray-200 rounded-lg p-3 text-center bg-gray-50">
                                <p className="text-sm text-gray-600">Total Sesi Pembinaan</p>
                                <p className="text-2xl font-bold text-gray-800">{reportStats.total}</p>
                            </div>
                            <div className="border border-gray-200 rounded-lg p-3 text-center bg-green-50">
                                <p className="text-sm text-gray-600">Siswa Dibina</p>
                                <p className="text-2xl font-bold text-green-700">{reportStats.studentCount} / {studentsList.length}</p>
                            </div>
                        </div>

                        {/* Persentase Aspek */}
                        <div className="space-y-3">
                            <p className="text-sm font-medium text-gray-700 mb-2">Distribusi Capaian Aspek:</p>
                            {Object.values(ASPEK_PEMBINAAN).map(aspek => {
                                const count = reportStats.aspek[aspek.id];
                                const percent = totalRecords === 0 ? 0 : Math.round((count / totalRecords) * 100);
                                return (
                                    <div key={aspek.id} className="flex items-center text-sm">
                                        <div className="w-32 font-medium text-gray-600">{aspek.label}</div>
                                        <div className="flex-1 mx-4 bg-gray-200 rounded-full h-2.5">
                                            <div className={`h-2.5 rounded-full ${aspek.bgColor.replace('bg-','bg-').replace('-100','-500')}`} style={{width: `${percent}%`}}></div>
                                        </div>
                                        <div className="w-12 text-right font-bold">{percent}%</div>
                                    </div>
                                )
                            })}
                        </div>
                    </div>

                    {/* Detail Evaluasi */}
                    <div>
                        <h4 className="font-bold text-gray-800 border-b border-gray-300 pb-2 mb-4">B. Detail Evaluasi & Rekomendasi</h4>
                        {totalRecords === 0 ? (
                            <p className="text-gray-500 italic text-center py-4">Belum ada data pada triwulan ini.</p>
                        ) : (
                            <div className="space-y-6">
                                {Object.values(ASPEK_PEMBINAAN).map(aspek => {
                                    const recordsAspek = qRecords.filter(r => r.aspek === aspek.id);
                                    if(recordsAspek.length === 0) return null;

                                    return (
                                        <div key={aspek.id} className="border border-gray-200 rounded-lg overflow-hidden break-inside-avoid">
                                            <div className={`px-4 py-2 font-bold ${aspek.bgColor} ${aspek.text} border-b border-gray-200 flex items-center`}>
                                                <aspek.icon size={16} className="mr-2" /> {aspek.label} ({recordsAspek.length} catatan)
                                            </div>
                                            <table className="w-full text-sm">
                                                <thead>
                                                    <tr className="bg-gray-50">
                                                        <th className="border-b border-gray-200 p-2 text-left w-1/4">Siswa</th>
                                                        <th className="border-b border-gray-200 p-2 text-left w-1/4">Indikator Dominan</th>
                                                        <th className="border-b border-gray-200 p-2 text-left">Evaluasi Umum & Tindak Lanjut</th>
                                                    </tr>
                                                </thead>
                                                <tbody className="divide-y divide-gray-100">
                                                    {/* Grouping by student within this aspect for summary view */}
                                                    {studentsList.map(student => {
                                                        const studentRecords = recordsAspek.filter(r => r.studentId === student.id);
                                                        if(studentRecords.length === 0) return null;
                                                        
                                                        // Get unique indicators
                                                        const indicators = [...new Set(studentRecords.map(r => r.indikator))].join(', ');
                                                        
                                                        // Get latest tindak lanjut
                                                        const latestRecord = studentRecords[studentRecords.length - 1];

                                                        return (
                                                            <tr key={`${aspek.id}-${student.id}`}>
                                                                <td className="p-2 align-top font-medium text-gray-800">{student.name}</td>
                                                                <td className="p-2 align-top text-gray-600">{indicators}</td>
                                                                <td className="p-2 align-top text-gray-600 italic">"{latestRecord.tindakLanjut}"</td>
                                                            </tr>
                                                        )
                                                    })}
                                                </tbody>
                                            </table>
                                        </div>
                                    )
                                })}
                            </div>
                        )}
                    </div>

                     {/* Signatures */}
                     <div className="mt-12 flex justify-between px-8">
                        <div className="text-center">
                            <p className="mb-16">Mengetahui,<br/>Kepala Sekolah</p>
                            <p className="font-bold underline">Drs. Nur Salim</p>
                            <p className="text-sm mt-1">NBM. -</p>
                        </div>
                        <div className="text-center">
                            <p className="mb-16">Bandar Lampung, {new Date().toLocaleDateString('id-ID', { day:'numeric', month:'long', year:'numeric'})}<br/>Guru Wali Kelas</p>
                            <p className="font-bold underline">{teacherProfile.name}</p>
                            <p className="text-sm mt-1">NBM/NIP. {teacherProfile.nip}</p>
                        </div>
                    </div>
                </div>
            </div>
        );
    };

    return (
        <div className="min-h-screen bg-gray-50 flex flex-col font-sans text-gray-900">
            {/* Header */}
            <header className="bg-green-700 border-b border-green-800 shadow-sm sticky top-0 z-10 print:hidden text-white">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
                    <div className="flex items-center space-x-3">
                        <BookOpen className="w-8 h-8 text-white" />
                        <div>
                            <h1 className="text-xl font-bold leading-tight">BinaWali SMP Muga</h1>
                            <p className="text-xs text-green-200">Sistem Informasi Pembinaan Guru Wali</p>
                        </div>
                    </div>
                    <div className="flex items-center space-x-4">
                        <div className="hidden md:flex items-center text-sm text-green-100">
                            <Calendar size={16} className="mr-2" />
                            {new Date().toLocaleDateString('id-ID', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}
                        </div>
                        <div className="flex items-center space-x-2 bg-green-800 px-3 py-1.5 rounded-full border border-green-600">
                            <User size={16} />
                            <span className="text-sm font-medium">{teacherProfile.name.split(',')[0]}</span>
                        </div>
                    </div>
                </div>
            </header>

            {/* Layout Body */}
            <div className="flex-1 max-w-7xl w-full mx-auto px-4 sm:px-6 lg:px-8 py-8 flex flex-col md:flex-row gap-8">
                
                {/* Sidebar Navigation */}
                <aside className="w-full md:w-64 shrink-0 print:hidden">
                    <nav className="space-y-1 bg-white p-4 rounded-xl shadow-sm border border-gray-100 sticky top-24">
                        <button
                            onClick={() => setActiveTab('dashboard')}
                            className={`w-full flex items-center space-x-3 px-4 py-3 rounded-lg text-sm font-medium transition-colors ${activeTab === 'dashboard' ? 'bg-green-50 text-green-700' : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'}`}
                        >
                            <PieChartIcon size={18} />
                            <span>Dashboard Utama</span>
                        </button>
                        
                        <div className="pt-4 pb-2">
                            <p className="px-4 text-xs font-semibold text-gray-400 uppercase tracking-wider">Manajemen Data</p>
                        </div>
                        <button
                            onClick={() => setActiveTab('input')}
                            className={`w-full flex items-center space-x-3 px-4 py-3 rounded-lg text-sm font-medium transition-colors ${activeTab === 'input' ? 'bg-green-50 text-green-700' : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'}`}
                        >
                            <Plus size={18} />
                            <span>Catat Pembinaan</span>
                        </button>
                        <button
                            onClick={() => setActiveTab('pengaturan')}
                            className={`w-full flex items-center space-x-3 px-4 py-3 rounded-lg text-sm font-medium transition-colors ${activeTab === 'pengaturan' ? 'bg-green-50 text-green-700' : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'}`}
                        >
                            <Settings size={18} />
                            <span>Data Siswa & Profil</span>
                        </button>

                        <div className="pt-4 pb-2">
                            <p className="px-4 text-xs font-semibold text-gray-400 uppercase tracking-wider">Laporan & Output</p>
                        </div>
                        <button
                            onClick={() => setActiveTab('rpp_pekan')}
                            className={`w-full flex items-center space-x-3 px-4 py-3 rounded-lg text-sm font-medium transition-colors ${activeTab === 'rpp_pekan' ? 'bg-green-50 text-green-700' : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'}`}
                        >
                            <Calendar size={18} />
                            <span>RPP Per Pekan</span>
                        </button>
                        <button
                            onClick={() => setActiveTab('laporan_triwulan')}
                            className={`w-full flex items-center space-x-3 px-4 py-3 rounded-lg text-sm font-medium transition-colors ${activeTab === 'laporan_triwulan' ? 'bg-green-50 text-green-700' : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'}`}
                        >
                            <FileText size={18} />
                            <span>Laporan 3 Bulanan</span>
                        </button>
                    </nav>
                </aside>

                {/* Main Content Area */}
                <main className="flex-1 w-full overflow-hidden">
                    {activeTab === 'dashboard' && renderDashboard()}
                    {activeTab === 'input' && renderInputForm()}
                    {activeTab === 'pengaturan' && renderPengaturan()}
                    {activeTab === 'rpp_pekan' && renderRencanaPekan()}
                    {activeTab === 'laporan_triwulan' && renderLaporanTriwulan()}
                </main>
            </div>
        </div>
    );
}
