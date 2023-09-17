import sqlite3
from calendar import monthrange
import datetime as dt
import xml.etree.ElementTree as ET

#

def dfmt(d):
    return (d.strftime('%d.%m.%y'))

def dsql(d):
    return d.strftime('%Y-%m-%d')

def fsql(s):
    t = [int(x) for x in s.split('-')];
    return dt.datetime(*t)

fmyfile = 'fmyfile'
c_y = 0
c_m = 0
day_count = 0

with open(fmyfile, encoding='utf=8') as fi:
    mydata = fi.readlines()

while True:
    s = mydata[0]
    del(mydata[0])
    if s[0] == '#':
        break
    if s[0] == 'y':
        c_y = int(s[2:])
    elif s[0] == 'm':
        c_m = int(s[2:])
    
workers = {}

mydata.sort()
for i in range(len(mydata)):
    s = str(mydata[i]).strip().split('=')
    workers[s[0]] = s[1]
    #.append(s[0])
    #mydata[i] = s[1]
    #print(mydata[i])
    
#print (*workers.keys(), sep='\n')
#print(*mydata)
sql = """select wname,  adate, alen, atype, ainfo 
    from absenses a join workers w on a.wid = w.wid 
    where adate between '{0}' and '{1}' order by wname, adate"""

if (c_y == 0) or (c_m == 0):
    print('Не найден месяц или год графика')
    exit()

mnames = ('январь', 'февраль', 'матр', 'апрел', 'май', 'июнь', 'июль', 'август', 'сентябр',
          'октябрь', 'ноябрь','декабрь')
print('Проверка отсутствий за месяц '+mnames[c_m - 1], c_y, 'года.')
print('')
    
absenses = dict()

#get -31 days of start c_m
fdate = dt.datetime(c_y,c_m,1)-dt.timedelta(31)
l = monthrange(c_y, c_m)
day_count = l[1]
edate = dt.datetime(c_y,c_m, l[1])
#print(dfmt(fdate), dfmt(edate))


tree = ET.parse(r'..\eth_graph.xini')
root = tree.getroot()


elem = root.find('data')
dbpath = elem.get('DBPath')

conn = sqlite3.connect(dbpath)
cur = conn.cursor()
sql = sql.format(dsql(fdate), dsql(edate))
#print(sql)
cur.execute(sql)

type_names = ['Не задано','Начало ночь','Конец ночь','Смена день','Охрана труда','Tехучеба',
    'Отпуск','Замещение','Bыходной','Межсменный промежуток',
    'С ночи в ночь', 'Прочее','Фактич. выходной','Ежедневная работа','Медкомиссия',
    'Обучение','Выезд на линию','Зарезервировано', 'Больничный', 'Переработка']

for r in cur:
    checking = False
    #print(r[0], fsql(r[1]), r[2], r[3], sep = '\t')
    d = workers[r[0]]
    d = d.split('|')
    fdate = dt.datetime(*[int(x) for x in r[1].split('-')])
    days = [0 for _ in range(day_count)]
    for i in range(r[2]):
        edate = fdate + dt.timedelta(i)
        if edate.month == c_m:
            days[edate.day - 1] = r[3]
            checking = True;
    if checking:
        print('Проверка:', r[0], '; c ', dfmt(fdate), ' по ', dfmt(fdate + dt.timedelta(r[2]-1)),
              '; Отсутствие:', type_names[r[3]], ' ('+r[4]+')', sep='')    
        #print(*days)
        for i in range(len(days)):
            if days[i] == 0: continue
            k = d[i].split('!')
            l = int(k[1])            
            if days[i] != l:
                print('День: ', str(i + 1).zfill(2),'; Тип: "', type_names[l], '", Часы: "',k[0], '"', sep='' )
        print('')
        
    

cur.close()
conn.close()
            
            
