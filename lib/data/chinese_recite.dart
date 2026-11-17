// 语文九年级上册 —— 古诗文背诵速过卡（flash 类型：看题→点显示答案→自评）
const List<Map<String, dynamic>> chineseRecite = [
  // ===== 岳阳楼记 =====
  {
    "id": "chy_rec_001", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 文言名篇", "lesson": "岳阳楼记",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "先天下之忧而忧，＿＿＿＿＿＿＿。",
    "options": [], "answer": "后天下之乐而乐",
    "analysis": "出自范仲淹《岳阳楼记》，表现以天下为己任的政治抱负。",
    "difficulty": 1
  },
  {
    "id": "chy_rec_002", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 文言名篇", "lesson": "岳阳楼记",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "不以物喜，＿＿＿＿＿＿＿。",
    "options": [], "answer": "不以己悲",
    "analysis": "出自《岳阳楼记》，互文见义，指不因外物好坏和个人得失而或喜或悲。",
    "difficulty": 1
  },
  {
    "id": "chy_rec_003", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 文言名篇", "lesson": "岳阳楼记",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "居庙堂之高则忧其民，＿＿＿＿＿＿＿＿＿。",
    "options": [], "answer": "处江湖之远则忧其君",
    "analysis": "出自《岳阳楼记》，写无论身处何位都心系君民。",
    "difficulty": 2
  },
  {
    "id": "chy_rec_004", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 文言名篇", "lesson": "岳阳楼记",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "衔远山，吞长江，＿＿＿＿＿＿，横无际涯。",
    "options": [], "answer": "浩浩汤汤",
    "analysis": "出自《岳阳楼记》，写洞庭湖的壮阔气象。",
    "difficulty": 2
  },

  // ===== 醉翁亭记 =====
  {
    "id": "chy_rec_005", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 文言名篇", "lesson": "醉翁亭记",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "醉翁之意不在酒，＿＿＿＿＿＿＿＿＿。",
    "options": [], "answer": "在乎山水之间也",
    "analysis": "出自欧阳修《醉翁亭记》，为千古名句。",
    "difficulty": 1
  },
  {
    "id": "chy_rec_006", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 文言名篇", "lesson": "醉翁亭记",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "山水之乐，＿＿＿＿＿＿＿＿＿＿＿。",
    "options": [], "answer": "得之心而寓之酒也",
    "analysis": "出自《醉翁亭记》，写欣赏山水的乐趣领会于心、寄托于酒。",
    "difficulty": 2
  },
  {
    "id": "chy_rec_007", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 文言名篇", "lesson": "醉翁亭记",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "野芳发而幽香，＿＿＿＿＿＿＿＿＿。",
    "options": [], "answer": "佳木秀而繁阴",
    "analysis": "出自《醉翁亭记》，写春夏之景。",
    "difficulty": 2
  },

  // ===== 湖心亭看雪 =====
  {
    "id": "chy_rec_008", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 文言名篇", "lesson": "湖心亭看雪",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "雾凇沆砀，天与云与山与水，＿＿＿＿＿＿。",
    "options": [], "answer": "上下一白",
    "analysis": "出自张岱《湖心亭看雪》，写雪后湖上浑然一白的景象。",
    "difficulty": 2
  },
  {
    "id": "chy_rec_009", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 文言名篇", "lesson": "湖心亭看雪",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "湖上影子，惟长堤一痕、湖心亭一点、＿＿＿＿＿＿＿＿＿＿、舟中人两三粒而已。",
    "options": [], "answer": "与余舟一芥",
    "analysis": "出自《湖心亭看雪》，以极简笔墨写雪夜湖景。",
    "difficulty": 3
  },

  // ===== 曹刿论战 =====
  {
    "id": "chy_rec_010", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 文言名篇", "lesson": "曹刿论战",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "一鼓作气，＿＿＿＿，＿＿＿＿。",
    "options": [], "answer": "再而衰，三而竭",
    "analysis": "出自《曹刿论战》，讲击鼓进军要一鼓作气。",
    "difficulty": 1
  },
  {
    "id": "chy_rec_011", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 文言名篇", "lesson": "曹刿论战",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "夫战，勇气也。＿＿＿＿＿＿＿，再而衰，三而竭。",
    "options": [], "answer": "一鼓作气",
    "analysis": "出自《曹刿论战》。",
    "difficulty": 2
  },
  {
    "id": "chy_rec_012", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 文言名篇", "lesson": "曹刿论战",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "小大之狱，虽不能察，＿＿＿＿＿。",
    "options": [], "answer": "必以情",
    "analysis": "出自《曹刿论战》，是鲁庄公所说的“可以一战”的依据之一。",
    "difficulty": 2
  },

  // ===== 邹忌讽齐王纳谏 =====
  {
    "id": "chy_rec_013", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 文言名篇", "lesson": "邹忌讽齐王纳谏",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "群臣吏民能面刺寡人之过者，＿＿＿＿＿；上书谏寡人者，＿＿＿＿＿。",
    "options": [], "answer": "受上赏；受中赏",
    "analysis": "出自《邹忌讽齐王纳谏》，写齐王下令广开言路。",
    "difficulty": 3
  },
  {
    "id": "chy_rec_014", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 文言名篇", "lesson": "邹忌讽齐王纳谏",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "燕、赵、韩、魏闻之，皆朝于齐。＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿。",
    "options": [], "answer": "此所谓战胜于朝廷",
    "analysis": "出自《邹忌讽齐王纳谏》，点明纳谏成效。",
    "difficulty": 3
  },

  // ===== 陈涉世家 =====
  {
    "id": "chy_rec_015", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 文言名篇", "lesson": "陈涉世家",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "王侯将相＿＿＿＿＿＿＿！",
    "options": [], "answer": "宁有种乎",
    "analysis": "出自《陈涉世家》，表现对封建等级制度的反抗精神。",
    "difficulty": 1
  },
  {
    "id": "chy_rec_016", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 文言名篇", "lesson": "陈涉世家",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "燕雀安知＿＿＿＿＿＿＿哉！",
    "options": [], "answer": "鸿鹄之志",
    "analysis": "出自《陈涉世家》，比喻远大的志向。",
    "difficulty": 1
  },
  {
    "id": "chy_rec_017", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 文言名篇", "lesson": "陈涉世家",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "苟富贵，＿＿＿＿＿。",
    "options": [], "answer": "无相忘",
    "analysis": "出自《陈涉世家》，陈涉对同伴说的话。",
    "difficulty": 1
  },

  // ===== 出师表 =====
  {
    "id": "chy_rec_018", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 文言名篇", "lesson": "出师表",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "受任于败军之际，＿＿＿＿＿＿＿＿。",
    "options": [], "answer": "奉命于危难之间",
    "analysis": "出自诸葛亮《出师表》，写临危受命。",
    "difficulty": 1
  },
  {
    "id": "chy_rec_019", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 文言名篇", "lesson": "出师表",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "先帝创业未半而中道崩殂，今天下三分，益州疲弊，＿＿＿＿＿＿＿。",
    "options": [], "answer": "此诚危急存亡之秋也",
    "analysis": "出自《出师表》开篇，点明形势危急。",
    "difficulty": 2
  },
  {
    "id": "chy_rec_020", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 文言名篇", "lesson": "出师表",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "苟全性命于乱世，＿＿＿＿＿＿＿＿＿。",
    "options": [], "answer": "不求闻达于诸侯",
    "analysis": "出自《出师表》，表明诸葛亮原本无意功名。",
    "difficulty": 2
  },
  {
    "id": "chy_rec_021", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 文言名篇", "lesson": "出师表",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "＿＿＿＿＿＿＿，不宜异同。",
    "options": [], "answer": "陟罚臧否",
    "analysis": "出自《出师表》，主张赏罚分明。",
    "difficulty": 3
  },

  // ===== 行路难 =====
  {
    "id": "chy_rec_022", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 诗词曲", "lesson": "行路难（其一）",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "长风破浪会有时，＿＿＿＿＿＿＿＿＿。",
    "options": [], "answer": "直挂云帆济沧海",
    "analysis": "李白《行路难》，表现乐观自信、坚信理想终能实现。",
    "difficulty": 1
  },
  {
    "id": "chy_rec_023", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 诗词曲", "lesson": "行路难（其一）",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "欲渡黄河冰塞川，＿＿＿＿＿＿＿＿＿。",
    "options": [], "answer": "将登太行雪满山",
    "analysis": "李白《行路难》，以自然险阻喻仕途艰难。",
    "difficulty": 2
  },
  {
    "id": "chy_rec_024", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 诗词曲", "lesson": "行路难（其一）",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "闲来垂钓碧溪上，＿＿＿＿＿＿＿＿＿。",
    "options": [], "answer": "忽复乘舟梦日边",
    "analysis": "李白《行路难》，用姜尚、伊尹的典故表达期待被重用。",
    "difficulty": 3
  },

  // ===== 酬乐天扬州初逢席上见赠 =====
  {
    "id": "chy_rec_025", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 诗词曲", "lesson": "酬乐天扬州初逢席上见赠",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "沉舟侧畔千帆过，＿＿＿＿＿＿＿＿＿。",
    "options": [], "answer": "病树前头万木春",
    "analysis": "刘禹锡此句蕴含新事物必将取代旧事物的哲理。",
    "difficulty": 1
  },
  {
    "id": "chy_rec_026", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 诗词曲", "lesson": "酬乐天扬州初逢席上见赠",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "巴山楚水凄凉地，＿＿＿＿＿＿＿＿＿。",
    "options": [], "answer": "二十三年弃置身",
    "analysis": "刘禹锡《酬乐天扬州初逢席上见赠》首联，慨叹贬谪之久。",
    "difficulty": 2
  },
  {
    "id": "chy_rec_027", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 诗词曲", "lesson": "酬乐天扬州初逢席上见赠",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "今日听君歌一曲，＿＿＿＿＿＿＿＿＿。",
    "options": [], "answer": "暂凭杯酒长精神",
    "analysis": "刘禹锡诗尾联，表达振作精神、积极进取的态度。",
    "difficulty": 2
  },

  // ===== 水调歌头 =====
  {
    "id": "chy_rec_028", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 诗词曲", "lesson": "水调歌头·明月几时有",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "但愿人长久，＿＿＿＿＿＿＿。",
    "options": [], "answer": "千里共婵娟",
    "analysis": "苏轼《水调歌头》，表达对亲人的美好祝愿。",
    "difficulty": 1
  },
  {
    "id": "chy_rec_029", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 诗词曲", "lesson": "水调歌头·明月几时有",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "人有悲欢离合，＿＿＿＿＿＿＿，此事古难全。",
    "options": [], "answer": "月有阴晴圆缺",
    "analysis": "苏轼《水调歌头》，以自然规律宽解人生缺憾。",
    "difficulty": 1
  },
  {
    "id": "chy_rec_030", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 诗词曲", "lesson": "水调歌头·明月几时有",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "明月几时有？＿＿＿＿＿＿＿。",
    "options": [], "answer": "把酒问青天",
    "analysis": "苏轼《水调歌头》开篇，气势豪迈。",
    "difficulty": 1
  },
  {
    "id": "chy_rec_031", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 诗词曲", "lesson": "水调歌头·明月几时有",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "不应有恨，＿＿＿＿＿＿＿＿＿？",
    "options": [], "answer": "何事长向别时圆",
    "analysis": "苏轼《水调歌头》，以埋怨月亮的问句写离别之愁。",
    "difficulty": 3
  },

  // ===== 月夜忆舍弟 =====
  {
    "id": "chy_rec_032", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 诗词曲", "lesson": "月夜忆舍弟",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "露从今夜白，＿＿＿＿＿＿＿。",
    "options": [], "answer": "月是故乡明",
    "analysis": "杜甫《月夜忆舍弟》，写思乡怀亲之情。",
    "difficulty": 1
  },
  {
    "id": "chy_rec_033", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 诗词曲", "lesson": "月夜忆舍弟",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "戍鼓断人行，＿＿＿＿＿＿＿。",
    "options": [], "answer": "边秋一雁声",
    "analysis": "杜甫《月夜忆舍弟》首联，写战乱中的边塞秋景。",
    "difficulty": 2
  },
  {
    "id": "chy_rec_034", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 诗词曲", "lesson": "月夜忆舍弟",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "寄书长不达，＿＿＿＿＿＿＿。",
    "options": [], "answer": "况乃未休兵",
    "analysis": "杜甫《月夜忆舍弟》尾联，写战乱中音书难通。",
    "difficulty": 3
  },

  // ===== 长沙过贾谊宅 =====
  {
    "id": "chy_rec_035", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 诗词曲", "lesson": "长沙过贾谊宅",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "汉文有道恩犹薄，＿＿＿＿＿＿＿＿＿。",
    "options": [], "answer": "湘水无情吊岂知",
    "analysis": "刘长卿《长沙过贾谊宅》，借贾谊遭贬抒发自己怀才不遇的悲愤。",
    "difficulty": 3
  },
  {
    "id": "chy_rec_036", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 诗词曲", "lesson": "长沙过贾谊宅",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "寂寂江山摇落处，＿＿＿＿＿＿＿＿＿。",
    "options": [], "answer": "怜君何事到天涯",
    "analysis": "刘长卿诗尾联，既怜贾谊也自怜。",
    "difficulty": 3
  },
  {
    "id": "chy_rec_037", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 诗词曲", "lesson": "长沙过贾谊宅",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "秋草独寻人去后，＿＿＿＿＿＿＿＿＿。",
    "options": [], "answer": "寒林空见日斜时",
    "analysis": "刘长卿《长沙过贾谊宅》颔联，写凭吊时的萧瑟景象。",
    "difficulty": 3
  },

  // ===== 综合默写 =====
  {
    "id": "chy_rec_038", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 文言名篇", "lesson": "岳阳楼记",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "《岳阳楼记》中描写洞庭湖月夜美景的句子是：浮光跃金，＿＿＿＿＿＿。",
    "options": [], "answer": "静影沉璧",
    "analysis": "“浮光跃金，静影沉璧”写月夜湖面波光与月影，一动一静。",
    "difficulty": 2
  },
  {
    "id": "chy_rec_039", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 文言名篇", "lesson": "醉翁亭记",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "《醉翁亭记》中写朝暮之景的句子：日出而林霏开，＿＿＿＿＿＿＿＿＿。",
    "options": [], "answer": "云归而岩穴暝",
    "analysis": "写琅琊山早晚明暗变化。",
    "difficulty": 2
  },
  {
    "id": "chy_rec_040", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 诗词曲", "lesson": "行路难（其一）",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "《行路难》中运用典故、表达希望被朝廷重用的句子是：＿＿＿＿＿＿＿＿，忽复乘舟梦日边。",
    "options": [], "answer": "闲来垂钓碧溪上",
    "analysis": "用姜太公渭水垂钓、伊尹梦日边受聘的典故。",
    "difficulty": 2
  }
  {
    "id": "chy_rec_041", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 诗词曲", "lesson": "行路难（其一）",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "金樽清酒斗十千，＿＿＿＿＿＿＿＿＿。",
    "options": [], "answer": "玉盘珍羞直万钱",
    "analysis": "李白《行路难》开篇，以美酒佳肴反衬内心苦闷。",
    "difficulty": 2
  },
  {
    "id": "chy_rec_042", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 诗词曲", "lesson": "行路难（其一）",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "停杯投箸不能食，＿＿＿＿＿＿＿＿＿。",
    "options": [], "answer": "拔剑四顾心茫然",
    "analysis": "李白《行路难》，写怀才不遇的苦闷。",
    "difficulty": 2
  },
  {
    "id": "chy_rec_043", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 诗词曲", "lesson": "行路难（其一）",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "行路难！行路难！多歧路，＿＿＿＿＿？",
    "options": [], "answer": "今安在",
    "analysis": "李白《行路难》，直抒前路迷茫之感。",
    "difficulty": 1
  },
  {
    "id": "chy_rec_044", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 诗词曲", "lesson": "酬乐天扬州初逢席上见赠",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "怀旧空吟闻笛赋，＿＿＿＿＿＿＿＿＿。",
    "options": [], "answer": "到乡翻似烂柯人",
    "analysis": "刘禹锡诗颔联，用向秀《思旧赋》和王质烂柯的典故写物是人非。",
    "difficulty": 3
  },
  {
    "id": "chy_rec_045", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 诗词曲", "lesson": "水调歌头·明月几时有",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "不知天上宫阙，＿＿＿＿＿＿＿。",
    "options": [], "answer": "今夕是何年",
    "analysis": "苏轼《水调歌头》，写对天上人间的遐想。",
    "difficulty": 2
  },
  {
    "id": "chy_rec_046", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 诗词曲", "lesson": "水调歌头·明月几时有",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "起舞弄清影，＿＿＿＿＿＿＿。",
    "options": [], "answer": "何似在人间",
    "analysis": "苏轼《水调歌头》，表达对人间的眷恋。",
    "difficulty": 2
  },
  {
    "id": "chy_rec_047", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 诗词曲", "lesson": "水调歌头·明月几时有",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "我欲乘风归去，＿＿＿＿＿＿＿＿＿，高处不胜寒。",
    "options": [], "answer": "又恐琼楼玉宇",
    "analysis": "苏轼《水调歌头》，写欲超脱又眷恋的复杂心境。",
    "difficulty": 3
  },
  {
    "id": "chy_rec_048", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 诗词曲", "lesson": "水调歌头·明月几时有",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "转朱阁，低绮户，＿＿＿＿＿。",
    "options": [], "answer": "照无眠",
    "analysis": "苏轼《水调歌头》，写月光移动与不眠之人。",
    "difficulty": 2
  },
  {
    "id": "chy_rec_049", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 诗词曲", "lesson": "月夜忆舍弟",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "有弟皆分散，＿＿＿＿＿＿＿。",
    "options": [], "answer": "无家问死生",
    "analysis": "杜甫《月夜忆舍弟》，写战乱中骨肉分离之痛。",
    "difficulty": 2
  },
  {
    "id": "chy_rec_050", "subject": "chinese", "grade": "九年级",
    "unit": "背诵默写 诗词曲", "lesson": "长沙过贾谊宅",
    "knowledge": "名句默写", "workbook": "自编", "type": "flash",
    "stem": "三年谪宦此栖迟，＿＿＿＿＿＿＿＿＿。",
    "options": [], "answer": "万古惟留楚客悲",
    "analysis": "刘长卿《长沙过贾谊宅》首联，借贾谊谪居起笔。",
    "difficulty": 3
  }
];
