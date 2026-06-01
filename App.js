/**
 * Wazni وزني — React Native App
 * by erihdev · v1.0.0
 *
 * Screens: Auth → (MyProgress | Challenge | MyCode)
 * Storage: AsyncStorage (per-user, keyed by email)
 */

import React, { useState, useEffect, useCallback } from 'react';
import {
  View, Text, TextInput, TouchableOpacity, ScrollView,
  StyleSheet, Alert, Dimensions, KeyboardAvoidingView,
  Platform, SafeAreaView, ActivityIndicator,
} from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import * as Clipboard from 'expo-clipboard';
import { NavigationContainer } from '@react-navigation/native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { BarChart, LineChart } from 'react-native-chart-kit';
import { StatusBar } from 'expo-status-bar';

const W = Dimensions.get('window').width;

// ─── Colors ───────────────────────────────────────────────────────────────────
const C = {
  brand:   '#185FA5',
  blue:    '#378ADD',
  green:   '#1D9E75',
  red:     '#E24B4A',
  orange:  '#D85A30',
  bg:      '#F5F5F3',
  card:    '#FFFFFF',
  text:    '#1A1A1A',
  text2:   '#666666',
  text3:   '#999999',
  border:  '#E0E0E0',
};

// ─── Storage helpers ───────────────────────────────────────────────────────────
const DB = {
  getUsers:    async ()      => JSON.parse(await AsyncStorage.getItem('wc_users')  || '{}'),
  saveUsers:   async u       => AsyncStorage.setItem('wc_users', JSON.stringify(u)),
  getData:     async email   => JSON.parse(await AsyncStorage.getItem('wc_data_'+email) || '[]'),
  saveData:    async (e,d)   => AsyncStorage.setItem('wc_data_'+e, JSON.stringify(d)),
  getSession:  async ()      => AsyncStorage.getItem('wc_sess'),
  saveSession: async email   => AsyncStorage.setItem('wc_sess', email),
  clearSession:async ()      => AsyncStorage.removeItem('wc_sess'),
  getCodes:    async ()      => JSON.parse(await AsyncStorage.getItem('wc_codes') || '{}'),
  saveCodes:   async m       => AsyncStorage.setItem('wc_codes', JSON.stringify(m)),
};

function genCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  return Array.from({ length: 6 }, () => chars[Math.floor(Math.random() * chars.length)]).join('');
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────
function TopBar({ user, onLogout }) {
  return (
    <View style={s.topBar}>
      <View style={s.brandRow}>
        <View style={s.brandLogo}><Text style={{ fontSize: 16 }}>⚖️</Text></View>
        <View>
          <Text style={s.brandName}>Wazni وزني</Text>
          <Text style={s.brandBy}>by erihdev</Text>
        </View>
      </View>
      {user && (
        <TouchableOpacity style={s.logoutBtn} onPress={onLogout}>
          <Text style={s.logoutText}>خروج</Text>
        </TouchableOpacity>
      )}
    </View>
  );
}

// ─── Auth Screen ──────────────────────────────────────────────────────────────
function AuthScreen({ onLogin }) {
  const [tab, setTab]       = useState('login');
  const [email, setEmail]   = useState('');
  const [pass, setPass]     = useState('');
  const [name, setName]     = useState('');
  const [start, setStart]   = useState('');
  const [goal, setGoal]     = useState('');
  const [err, setErr]       = useState('');

  async function doLogin() {
    setErr('');
    const users = await DB.getUsers();
    if (!email || !pass)              { setErr('يرجى ملء جميع الحقول'); return; }
    if (!users[email.toLowerCase()])  { setErr('البريد غير مسجّل'); return; }
    if (users[email.toLowerCase()].pass !== btoa(pass)) { setErr('كلمة المرور غير صحيحة'); return; }
    const u = { email: email.toLowerCase(), ...users[email.toLowerCase()] };
    await DB.saveSession(u.email);
    onLogin(u);
  }

  async function doRegister() {
    setErr('');
    const trimEmail = email.trim().toLowerCase();
    if (!name.trim() || !trimEmail || !pass) { setErr('يرجى ملء الحقول المطلوبة'); return; }
    if (pass.length < 6)  { setErr('كلمة المرور قصيرة (6+ أحرف)'); return; }
    if (!/\S+@\S+\.\S+/.test(trimEmail)) { setErr('صيغة البريد غير صحيحة'); return; }
    const users = await DB.getUsers();
    if (users[trimEmail]) { setErr('البريد مسجّل مسبقاً'); return; }
    let code = genCode();
    const codes = await DB.getCodes();
    while (codes[code]) code = genCode();
    codes[code] = trimEmail;
    await DB.saveCodes(codes);
    users[trimEmail] = {
      name: name.trim(), pass: btoa(pass),
      startWeight: parseFloat(start) || null,
      goalWeight:  parseFloat(goal)  || null,
      code, challenges: []
    };
    await DB.saveUsers(users);
    if (parseFloat(start) > 0) {
      await DB.saveData(trimEmail, [{ label: 'البداية', weight: parseFloat(start) }]);
    }
    const u = { email: trimEmail, ...users[trimEmail] };
    await DB.saveSession(u.email);
    onLogin(u);
  }

  return (
    <KeyboardAvoidingView style={{ flex:1 }} behavior={Platform.OS==='ios'?'padding':'height'}>
      <ScrollView contentContainerStyle={s.authScroll} keyboardShouldPersistTaps="handled">
        <View style={s.authHero}>
          <Text style={{ fontSize:44 }}>🏆</Text>
          <Text style={s.heroTitle}>وزني</Text>
          <Text style={s.heroSub}>تتبعي وزنك وتنافسي مع صديقاتك</Text>
        </View>

        <View style={s.tabRow}>
          {['login','register'].map(t => (
            <TouchableOpacity key={t} style={[s.tabBtn, tab===t && s.tabBtnActive]} onPress={() => { setTab(t); setErr(''); }}>
              <Text style={[s.tabBtnText, tab===t && s.tabBtnTextActive]}>
                {t==='login' ? 'تسجيل الدخول' : 'حساب جديد'}
              </Text>
            </TouchableOpacity>
          ))}
        </View>

        {tab==='login' ? (
          <>
            <Field label="البريد الإلكتروني"><TextInput style={s.input} value={email} onChangeText={setEmail} placeholder="example@email.com" keyboardType="email-address" autoCapitalize="none" /></Field>
            <Field label="كلمة المرور"><TextInput style={s.input} value={pass} onChangeText={setPass} placeholder="••••••••" secureTextEntry /></Field>
          </>
        ) : (
          <>
            <Field label="الاسم *"><TextInput style={s.input} value={name} onChangeText={setName} placeholder="اسمك" /></Field>
            <Field label="البريد الإلكتروني *"><TextInput style={s.input} value={email} onChangeText={setEmail} placeholder="example@email.com" keyboardType="email-address" autoCapitalize="none" /></Field>
            <Field label="كلمة المرور * (6+ أحرف)"><TextInput style={s.input} value={pass} onChangeText={setPass} placeholder="••••••••" secureTextEntry /></Field>
            <Field label="الوزن الابتدائي (كغ)"><TextInput style={s.input} value={start} onChangeText={setStart} placeholder="90" keyboardType="decimal-pad" /></Field>
            <Field label="الوزن الهدف (كغ)"><TextInput style={s.input} value={goal} onChangeText={setGoal} placeholder="75" keyboardType="decimal-pad" /></Field>
          </>
        )}

        {!!err && <Text style={s.errText}>{err}</Text>}
        <TouchableOpacity style={s.btnPrimary} onPress={tab==='login' ? doLogin : doRegister}>
          <Text style={s.btnPrimaryText}>{tab==='login' ? 'دخول' : 'إنشاء الحساب'}</Text>
        </TouchableOpacity>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

// ─── My Progress Screen ───────────────────────────────────────────────────────
function MyProgressScreen({ user }) {
  const [data, setData]       = useState([]);
  const [label, setLabel]     = useState('');
  const [weight, setWeight]   = useState('');
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    setData(await DB.getData(user.email));
    setLoading(false);
  }, [user.email]);

  useEffect(() => { load(); }, [load]);

  async function addEntry() {
    if (!label.trim() || !parseFloat(weight)) return;
    const newData = [...data, { label: label.trim(), weight: parseFloat(weight) }];
    await DB.saveData(user.email, newData);
    setData(newData); setLabel(''); setWeight('');
  }

  async function removeEntry(i) {
    Alert.alert('حذف', 'هل تريدين حذف هذه القراءة؟', [
      { text: 'إلغاء', style: 'cancel' },
      { text: 'حذف', style: 'destructive', onPress: async () => {
        const nd = data.filter((_,idx) => idx!==i);
        await DB.saveData(user.email, nd); setData(nd);
      }}
    ]);
  }

  const weights  = data.map(e => e.weight);
  const startW   = user.startWeight || weights[0];
  const last     = weights[weights.length-1];
  const loss     = startW && last ? startW - last : 0;
  const pct      = user.goalWeight && startW && startW > user.goalWeight
    ? Math.min(100, Math.max(0, Math.round(((startW-last)/(startW-user.goalWeight))*100))) : null;
  const maxW     = weights.length ? Math.max(...weights) : 0;

  const chartData = data.length > 0 ? {
    labels: data.map(e => e.label.substring(0,5)),
    datasets: [{ data: weights }]
  } : null;

  if (loading) return <ActivityIndicator style={{ marginTop:60 }} color={C.brand} />;

  return (
    <ScrollView style={s.screen} contentContainerStyle={{ padding:14, paddingBottom:30 }} keyboardShouldPersistTaps="handled">

      {/* Stats */}
      <View style={s.statGrid}>
        <StatBox label="الحالي"    value={last ? last.toFixed(1) : '—'}              unit="كغ" />
        <StatBox label="النقص"     value={last ? (loss>=0?'-':'+')+Math.abs(loss).toFixed(1) : '—'} unit="كغ" color={C.green} />
        <StatBox label="الهدف"     value={user.goalWeight ? user.goalWeight.toFixed(1) : '—'}        unit="كغ" color={C.brand} />
        <StatBox label="الإنجاز"   value={pct !== null ? pct : '—'}                  unit="%" color="#639922" />
      </View>

      {/* Add entry */}
      <View style={s.card}>
        <View style={{ flexDirection:'row', gap:8, alignItems:'flex-end' }}>
          <View style={{ flex:1 }}>
            <Text style={s.fieldLabel}>الفترة / التاريخ</Text>
            <TextInput style={s.input} value={label} onChangeText={setLabel} placeholder="أسبوع 1" />
          </View>
          <View style={{ width:90 }}>
            <Text style={s.fieldLabel}>الوزن</Text>
            <TextInput style={s.input} value={weight} onChangeText={setWeight} placeholder="85.0" keyboardType="decimal-pad" />
          </View>
          <TouchableOpacity style={[s.iconBtn, { backgroundColor:C.brand }]} onPress={addEntry}>
            <Text style={{ color:'#fff', fontSize:20 }}>+</Text>
          </TouchableOpacity>
        </View>
      </View>

      {/* Chart */}
      {chartData && (
        <View style={[s.card, { paddingHorizontal:0, overflow:'hidden' }]}>
          <BarChart
            data={chartData}
            width={W - 28}
            height={210}
            fromZero={false}
            yAxisSuffix=""
            chartConfig={{
              backgroundColor: C.card, backgroundGradientFrom: C.card, backgroundGradientTo: C.card,
              decimalPlaces: 1, color: (opacity=1, i) => {
                if (data[i] && data[i].weight === maxW) return `rgba(216,90,48,${opacity})`;
                return `rgba(55,138,221,${opacity})`;
              },
              labelColor: () => C.text2, style: { borderRadius:8 },
              propsForLabels: { fontSize: 10 }
            }}
            style={{ borderRadius:8 }}
          />
          {user.goalWeight && (
            <Text style={{ fontSize:11, color:C.green, textAlign:'center', paddingBottom:8 }}>
              ─ ─ الهدف: {user.goalWeight.toFixed(1)} كغ
            </Text>
          )}
        </View>
      )}

      {/* Entries list */}
      {data.length > 0 && (
        <View style={s.card}>
          <Text style={s.sectionTitle}>السجل</Text>
          {data.slice().reverse().map((e, ri) => {
            const i    = data.length - 1 - ri;
            const prev = i > 0 ? data[i-1].weight : null;
            const diff = prev !== null ? e.weight - prev : null;
            return (
              <View key={i} style={s.entryRow}>
                <Text style={{ color:C.text2, fontSize:13 }}>{e.label}</Text>
                <View style={{ flexDirection:'row', alignItems:'center', gap:6 }}>
                  <Text style={{ fontWeight:'700', fontSize:13 }}>{e.weight.toFixed(1)} كغ</Text>
                  {diff !== null && (
                    <Text style={{ fontSize:11, color: diff<=0 ? C.green : C.red }}>
                      {diff<=0?'▼':'▲'} {Math.abs(diff).toFixed(1)}
                    </Text>
                  )}
                </View>
                <TouchableOpacity onPress={() => removeEntry(i)}>
                  <Text style={{ color:C.text3, fontSize:16 }}>🗑</Text>
                </TouchableOpacity>
              </View>
            );
          })}
        </View>
      )}
    </ScrollView>
  );
}

// ─── Challenge Screen ─────────────────────────────────────────────────────────
function ChallengeScreen({ user, setUser }) {
  const [code, setCode]             = useState('');
  const [challenges, setChallenges] = useState([]);
  const [err, setErr]               = useState('');

  useEffect(() => {
    loadChallenges();
  }, []);

  async function loadChallenges() {
    const users = await DB.getUsers();
    setChallenges(users[user.email]?.challenges || []);
  }

  async function addChallenge() {
    setErr('');
    const c = code.trim().toUpperCase();
    if (!c) { setErr('أدخلي الكود أولاً'); return; }
    if (c === user.code) { setErr('هذا كودك الشخصي!'); return; }
    const codes  = await DB.getCodes();
    if (!codes[c]) { setErr('الكود غير موجود'); return; }
    const fEmail = codes[c];
    const users  = await DB.getUsers();
    const myUser = users[user.email];
    if (!myUser.challenges) myUser.challenges = [];
    if (myUser.challenges.includes(fEmail)) { setErr('أنتِ في تحدٍ معها مسبقاً'); return; }
    myUser.challenges.push(fEmail);
    const fUser = users[fEmail];
    if (!fUser.challenges) fUser.challenges = [];
    if (!fUser.challenges.includes(user.email)) fUser.challenges.push(user.email);
    await DB.saveUsers(users);
    setCode('');
    loadChallenges();
  }

  async function removeChallenge(fEmail) {
    Alert.alert('إلغاء التحدي', 'هل تريدين إلغاء هذا التحدي؟', [
      { text: 'لا', style: 'cancel' },
      { text: 'نعم', style: 'destructive', onPress: async () => {
        const users = await DB.getUsers();
        users[user.email].challenges = (users[user.email].challenges||[]).filter(e=>e!==fEmail);
        if (users[fEmail]) users[fEmail].challenges = (users[fEmail].challenges||[]).filter(e=>e!==user.email);
        await DB.saveUsers(users); loadChallenges();
      }}
    ]);
  }

  return (
    <ScrollView style={s.screen} contentContainerStyle={{ padding:14, paddingBottom:30 }}>

      <View style={s.card}>
        <Text style={s.sectionTitle}>🤝 تحدي جديد</Text>
        <Text style={{ fontSize:13, color:C.text2, marginBottom:10 }}>أدخلي كود صديقتك لبدء التنافس</Text>
        <View style={{ flexDirection:'row', gap:8 }}>
          <TextInput
            style={[s.input, { flex:1, fontFamily: Platform.OS==='ios'?'Courier':'monospace', letterSpacing:3, textAlign:'center' }]}
            value={code} onChangeText={t => setCode(t.toUpperCase())}
            placeholder="الكود" autoCapitalize="characters" maxLength={6}
          />
          <TouchableOpacity style={[s.iconBtn, { backgroundColor:C.brand, paddingHorizontal:16 }]} onPress={addChallenge}>
            <Text style={{ color:'#fff', fontSize:14, fontWeight:'700' }}>ابدئي 🚀</Text>
          </TouchableOpacity>
        </View>
        {!!err && <Text style={[s.errText, { marginTop:8 }]}>{err}</Text>}
      </View>

      {challenges.length === 0 ? (
        <View style={[s.card, { alignItems:'center', padding:30 }]}>
          <Text style={{ fontSize:36, marginBottom:8 }}>🏆</Text>
          <Text style={{ fontSize:15, fontWeight:'700', marginBottom:4 }}>لا يوجد تحديات بعد</Text>
          <Text style={{ fontSize:13, color:C.text2, textAlign:'center' }}>أضيفي كود صديقتك لتبدأي المنافسة!</Text>
        </View>
      ) : (
        <ChallengeList challenges={challenges} user={user} onRemove={removeChallenge} />
      )}
    </ScrollView>
  );
}

function ChallengeList({ challenges, user, onRemove }) {
  const [items, setItems] = useState([]);

  useEffect(() => { loadItems(); }, [challenges]);

  async function loadItems() {
    const users = await DB.getUsers();
    const myData  = await DB.getData(user.email);
    const myW     = myData.map(e=>e.weight);
    const myLast  = myW.length ? myW[myW.length-1] : null;
    const myStart = user.startWeight || myW[0] || null;
    const myLoss  = myStart&&myLast ? myStart-myLast : 0;
    const myPct   = user.goalWeight&&myStart&&myStart>user.goalWeight
      ? Math.min(100,Math.max(0,Math.round(((myStart-myLast)/(myStart-user.goalWeight))*100))) : null;

    const result = await Promise.all(challenges.map(async fEmail => {
      const fUser  = users[fEmail]; if (!fUser) return null;
      const fData  = await DB.getData(fEmail);
      const fW     = fData.map(e=>e.weight);
      const fLast  = fW.length ? fW[fW.length-1] : null;
      const fStart = fUser.startWeight || fW[0] || null;
      const fLoss  = fStart&&fLast ? fStart-fLast : 0;
      const fPct   = fUser.goalWeight&&fStart&&fStart>fUser.goalWeight
        ? Math.min(100,Math.max(0,Math.round(((fStart-fLast)/(fStart-fUser.goalWeight))*100))) : null;
      const iWin   = myPct!==null&&fPct!==null ? myPct>=fPct : myLoss>=fLoss;
      return { fEmail, fUser, fData, myData, myLoss, fLoss, myPct, fPct, iWin };
    }));
    setItems(result.filter(Boolean));
  }

  return (
    <>
      {items.map(({ fEmail, fUser, fData, myData, myLoss, fLoss, myPct, fPct, iWin }) => (
        <View key={fEmail} style={s.card}>
          <View style={{ flexDirection:'row', justifyContent:'space-between', marginBottom:10 }}>
            <Text style={{ fontSize:14, fontWeight:'700' }}>⚔️ {fUser.name}</Text>
            <TouchableOpacity onPress={() => onRemove(fEmail)}>
              <Text style={{ color:C.red, fontSize:12 }}>إلغاء</Text>
            </TouchableOpacity>
          </View>
          <View style={{ flexDirection:'row', gap:10, marginBottom:10 }}>
            <PlayerBox name={user.name} loss={myLoss} pct={myPct} winning={iWin} color={C.brand} />
            <PlayerBox name={fUser.name} loss={fLoss} pct={fPct} winning={!iWin} color={C.orange} />
          </View>
          {myData.length>0 && fData.length>0 && (
            <CompareChart myData={myData} fData={fData} myName={user.name} fName={fUser.name} />
          )}
        </View>
      ))}
    </>
  );
}

function PlayerBox({ name, loss, pct, winning, color }) {
  return (
    <View style={[s.playerBox, winning && s.playerBoxWinning]}>
      <View style={[s.avatar, { backgroundColor: color+'22', borderColor: color }]}>
        <Text style={{ fontWeight:'700', fontSize:13, color }}>{name.substring(0,2).toUpperCase()}</Text>
      </View>
      <Text style={{ fontSize:12, fontWeight:'700', marginTop:5 }}>{name.split(' ')[0]}</Text>
      <Text style={{ fontSize:11, color:C.text2 }}>نقص: <Text style={{ color:C.green, fontWeight:'700' }}>{loss.toFixed(1)}</Text> كغ</Text>
      {pct!==null && <Text style={{ fontSize:11, color:C.text2 }}>إنجاز: <Text style={{ fontWeight:'700' }}>{pct}%</Text></Text>}
      {winning && <Text style={{ fontSize:14, marginTop:3 }}>🏆</Text>}
    </View>
  );
}

function CompareChart({ myData, fData, myName, fName }) {
  const chartData = {
    labels: myData.map(e => e.label.substring(0,4)),
    datasets: [
      { data: myData.map(e=>e.weight), color: (o=1) => `rgba(55,138,221,${o})`, strokeWidth:2 },
      { data: fData.map(e=>e.weight),  color: (o=1) => `rgba(216,90,48,${o})`,  strokeWidth:2 },
    ],
    legend: [myName.split(' ')[0], fName.split(' ')[0]]
  };
  const all  = [...myData.map(e=>e.weight),...fData.map(e=>e.weight)];
  const minV = Math.min(...all), maxV = Math.max(...all);
  return (
    <LineChart
      data={chartData}
      width={W - 56}
      height={160}
      chartConfig={{
        backgroundColor: C.card, backgroundGradientFrom: C.card, backgroundGradientTo: C.card,
        decimalPlaces:1, color:(o=1)=>`rgba(0,0,0,${o*0.7})`,
        labelColor:()=>C.text2, propsForLabels:{fontSize:9},
        propsForDots:{ r:'4' }
      }}
      bezier
      style={{ borderRadius:8, marginTop:4 }}
      fromZero={false}
    />
  );
}

// ─── My Code Screen ───────────────────────────────────────────────────────────
function MyCodeScreen({ user }) {
  const [copied, setCopied]   = useState(false);
  const [friends, setFriends] = useState([]);

  useEffect(() => { loadFriends(); }, []);

  async function loadFriends() {
    const users  = await DB.getUsers();
    const myUser = users[user.email];
    const list   = await Promise.all((myUser.challenges||[]).map(async e => {
      const u = users[e]; return u ? { email:e, name:u.name } : null;
    }));
    setFriends(list.filter(Boolean));
  }

  async function copy() {
    await Clipboard.setStringAsync(user.code);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  }

  return (
    <ScrollView style={s.screen} contentContainerStyle={{ padding:14, paddingBottom:30 }}>
      <View style={s.card}>
        <Text style={s.sectionTitle}>📤 كودك الشخصي</Text>
        <Text style={{ fontSize:13, color:C.text2, marginBottom:14 }}>شاركيه مع صديقاتك ليتحدين معك</Text>
        <View style={s.codeBox}>
          <Text style={s.codeText}>{user.code}</Text>
        </View>
        <TouchableOpacity style={[s.btnPrimary, { marginTop:12 }]} onPress={copy}>
          <Text style={s.btnPrimaryText}>{copied ? '✓ تم النسخ!' : '📋 نسخ الكود'}</Text>
        </TouchableOpacity>
      </View>

      <View style={s.card}>
        <Text style={s.sectionTitle}>تحدياتي النشطة</Text>
        {friends.length === 0 ? (
          <Text style={{ fontSize:13, color:C.text2 }}>لا يوجد تحديات بعد</Text>
        ) : friends.map(f => (
          <View key={f.email} style={s.entryRow}>
            <View style={[s.avatar, { width:32, height:32 }]}>
              <Text style={{ fontWeight:'700', fontSize:11, color:C.brand }}>{f.name.substring(0,2).toUpperCase()}</Text>
            </View>
            <Text style={{ fontSize:13, fontWeight:'600' }}>{f.name}</Text>
          </View>
        ))}
      </View>

      <View style={[s.card, { alignItems:'center' }]}>
        <Text style={{ fontSize:11, color:C.text3 }}>Wazni وزني · by erihdev</Text>
      </View>
    </ScrollView>
  );
}

// ─── Shared UI Atoms ──────────────────────────────────────────────────────────
function Field({ label, children }) {
  return (
    <View style={s.field}>
      {label && <Text style={s.fieldLabel}>{label}</Text>}
      {children}
    </View>
  );
}
function StatBox({ label, value, unit, color }) {
  return (
    <View style={s.statBox}>
      <Text style={s.statLabel}>{label}</Text>
      <Text style={[s.statVal, color && { color }]}>{value}</Text>
      <Text style={s.statUnit}>{unit}</Text>
    </View>
  );
}

// ─── Tab Navigator ────────────────────────────────────────────────────────────
const Tab = createBottomTabNavigator();

function AppTabs({ user, onLogout, setUser }) {
  return (
    <Tab.Navigator
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: C.brand,
        tabBarInactiveTintColor: C.text3,
        tabBarStyle: { borderTopColor: C.border, backgroundColor: C.card },
        tabBarLabelStyle: { fontSize: 11 }
      }}
    >
      <Tab.Screen name="تقدمي"   options={{ tabBarIcon: ({ color }) => <Text style={{ fontSize:20 }}>📊</Text> }}>
        {() => <MyProgressScreen user={user} />}
      </Tab.Screen>
      <Tab.Screen name="التحدي"  options={{ tabBarIcon: ({ color }) => <Text style={{ fontSize:20 }}>🏆</Text> }}>
        {() => <ChallengeScreen user={user} setUser={setUser} />}
      </Tab.Screen>
      <Tab.Screen name="كودي"    options={{ tabBarIcon: ({ color }) => <Text style={{ fontSize:20 }}>🔑</Text> }}>
        {() => <MyCodeScreen user={user} />}
      </Tab.Screen>
    </Tab.Navigator>
  );
}

// ─── Root App ─────────────────────────────────────────────────────────────────
export default function App() {
  const [user, setUser]       = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    (async () => {
      const sess  = await DB.getSession();
      if (sess) {
        const users = await DB.getUsers();
        if (users[sess]) setUser({ email:sess, ...users[sess] });
      }
      setLoading(false);
    })();
  }, []);

  async function handleLogout() {
    await DB.clearSession();
    setUser(null);
  }

  if (loading) {
    return (
      <SafeAreaView style={{ flex:1, justifyContent:'center', alignItems:'center', backgroundColor:C.bg }}>
        <Text style={{ fontSize:40, marginBottom:12 }}>⚖️</Text>
        <ActivityIndicator color={C.brand} />
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={{ flex:1, backgroundColor: user ? C.bg : C.card }}>
      <StatusBar style="light" backgroundColor={C.brand} />
      <TopBar user={user} onLogout={handleLogout} />
      {user ? (
        <NavigationContainer>
          <AppTabs user={user} onLogout={handleLogout} setUser={setUser} />
        </NavigationContainer>
      ) : (
        <AuthScreen onLogin={setUser} />
      )}
    </SafeAreaView>
  );
}

// ─── Styles ───────────────────────────────────────────────────────────────────
const s = StyleSheet.create({
  // top bar
  topBar:        { backgroundColor:C.brand, paddingHorizontal:16, paddingVertical:12, flexDirection:'row', justifyContent:'space-between', alignItems:'center' },
  brandRow:      { flexDirection:'row', alignItems:'center', gap:10 },
  brandLogo:     { width:32, height:32, backgroundColor:'rgba(255,255,255,0.2)', borderRadius:8, justifyContent:'center', alignItems:'center' },
  brandName:     { color:'#fff', fontSize:16, fontWeight:'700' },
  brandBy:       { color:'rgba(255,255,255,0.6)', fontSize:9, letterSpacing:0.5 },
  logoutBtn:     { backgroundColor:'rgba(255,255,255,0.18)', paddingHorizontal:12, paddingVertical:6, borderRadius:6 },
  logoutText:    { color:'#fff', fontSize:12, fontWeight:'600' },
  // screens
  screen:        { flex:1, backgroundColor:C.bg },
  authScroll:    { padding:20, paddingBottom:40 },
  // hero
  authHero:      { alignItems:'center', marginBottom:24, marginTop:8 },
  heroTitle:     { fontSize:26, fontWeight:'800', marginTop:8, color:C.text },
  heroSub:       { fontSize:13, color:C.text2, marginTop:4 },
  // tabs
  tabRow:        { flexDirection:'row', borderBottomWidth:1, borderBottomColor:C.border, marginBottom:20 },
  tabBtn:        { flex:1, paddingVertical:10, alignItems:'center', borderBottomWidth:2, borderBottomColor:'transparent' },
  tabBtnActive:  { borderBottomColor:C.brand },
  tabBtnText:    { fontSize:14, color:C.text2 },
  tabBtnTextActive: { color:C.brand, fontWeight:'700' },
  // form
  field:         { marginBottom:13 },
  fieldLabel:    { fontSize:12, color:C.text2, fontWeight:'600', marginBottom:5 },
  input:         { borderWidth:1, borderColor:C.border, borderRadius:8, paddingHorizontal:13, paddingVertical:Platform.OS==='ios'?12:10, fontSize:15, color:C.text, backgroundColor:C.card },
  errText:       { fontSize:12, color:C.red },
  // buttons
  btnPrimary:    { backgroundColor:C.brand, borderRadius:12, paddingVertical:14, alignItems:'center' },
  btnPrimaryText:{ color:'#fff', fontSize:15, fontWeight:'700' },
  iconBtn:       { width:44, height:44, borderRadius:8, justifyContent:'center', alignItems:'center' },
  // cards
  card:          { backgroundColor:C.card, borderRadius:14, padding:14, marginBottom:12, borderWidth:1, borderColor:C.border },
  sectionTitle:  { fontSize:14, fontWeight:'700', marginBottom:10, color:C.text },
  // stats
  statGrid:      { flexDirection:'row', flexWrap:'wrap', gap:8, marginBottom:12 },
  statBox:       { flex:1, minWidth:'45%', backgroundColor:C.card, borderRadius:10, padding:12, alignItems:'center', borderWidth:1, borderColor:C.border },
  statLabel:     { fontSize:11, color:C.text2, marginBottom:3 },
  statVal:       { fontSize:22, fontWeight:'800', color:C.text },
  statUnit:      { fontSize:10, color:C.text3, marginTop:1 },
  // entries
  entryRow:      { flexDirection:'row', justifyContent:'space-between', alignItems:'center', paddingVertical:8, paddingHorizontal:10, backgroundColor:C.bg, borderRadius:8, marginBottom:5 },
  // challenge
  playerBox:     { flex:1, alignItems:'center', padding:10, borderRadius:10, borderWidth:1, borderColor:C.border },
  playerBoxWinning: { borderWidth:2, borderColor:C.green },
  avatar:        { width:38, height:38, borderRadius:19, justifyContent:'center', alignItems:'center', borderWidth:1, borderColor:C.brand, backgroundColor:C.brand+'15' },
  // code
  codeBox:       { backgroundColor:C.bg, borderRadius:10, paddingVertical:16, alignItems:'center' },
  codeText:      { fontFamily: Platform.OS==='ios'?'Courier New':'monospace', fontSize:28, fontWeight:'800', color:C.brand, letterSpacing:6 },
});
