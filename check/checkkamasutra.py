"""
Просмотр Данных человека в камасутре
Управление временными данными -> Рабочее место/УправлВремДанПерсонала
В календарике выбираем интервал
Последняя Иконка -  Временное добавление сотрудников - выбираем чела
и смотрим его

"""
#проверяем совпадение файла из камасутры и нашего файла графика

#fmyfile = r'e:\projects\pyprj\k\октябрь план 1 2022.gr'
#fmyfile = r'e:\projects\pyprj\k\сентябрь без П 2022 камасутра 2.gr'
#fmyfile = r'e:\projects\pyprj\k\ноябрь 2022 камасутра.gr'
#fmyfile = r'e:\projects\pyprj\k\июнь 2023 печать.gr'
#fmyfile = r'e:\projects\pyprj\k\май 2023 печать.gr'
#fmyfile = r'e:\projects\pyprj\k\апрель 2023 печать.gr'
fmyfile = 'fmyfile'
#fmyfile = r'e:\projects\pyprj\k\март камасутра 4 2023.gr'
#fkfile = r'e:\projects\pyprj\k\окт2022'
#fkfile = r'e:\projects\pyprj\k\сен2022'
#fkfile = r'e:\projects\pyprj\k\ноя2022'
#fkfile = r'e:\projects\pyprj\k\дек2022'
#fkfile = r'e:\projects\pyprj\k\июн23'
#fkfile = r'e:\projects\pyprj\k\апр23'
#fkfile = r'e:\projects\pyprj\k\май23'
fkfile = 'fkfile'

SO = False



with open(fmyfile, encoding='utf=8') as fi:
    mydata = fi.readlines()

while True:
    #print(mydata[0])
    if mydata[0][0] != '#':
        del (mydata[0])
    else:
        del (mydata[0])
        break
workers = []

mydata.sort()
for i in range(len(mydata)):
    s = str(mydata[i]).strip().split('=')
    workers.append(s[0])
    mydata[i] = s[1]
    #print(mydata[i])
    
print (*workers)

with open(fkfile, encoding='utf=8') as fi:
    kdata = fi.readlines()

cset = {'0','1','2','3','4','5','6','7','8','9','0','В','М','П',
        '.',',','Н','H',chr(9),'О', 'Т', 'O', 'T','К','K','*', "Ф", '/'}
for i in range(len(kdata)):
    k = ''
    s = kdata[i].strip()
    for c in s:
        if c in cset:
            k = k + c
        else:
            print(c, end='')
    kdata[i] = k
print()

#print(*kdata)

for i in range(len(kdata)):
    kdata[i] = kdata[i].split(chr(9))

#print (*kdata)    

for i in range(len(mydata)):
    mydata[i] = mydata[i].split('|')
    
#print(*mydata)

#словарь соответствий нас и камасутры

km = {

      '!6':'МП',
      '!12':'ФВ',
      '!12':'ФВ',
      '!18':'МП',
      '0!11':'МП',
      'В!8':'В',
      'В!6':'В',
      'В!15':'В',
      'ОТ!6':'ОТ01',
      '!9':'МП',
      '!15':'МП',
      '2!3':'2',
      '2!4':'2',
      '2!5':'2',
      '3!4':'3',
      '3!5':'3',
      '3!6':'ОТ01',
      '4!1':'4,5Н',
      '4!4':'4',
      '4!5':'4',
      '4!6':'4,5Н',
      '4!11':'4,5Н',
      '4!15':'4,5Н',
      '4!16':'4',
      '4!18':'4,5Н',
      '5!4':'5',
      '6!3':'6',
      '6!4':'6',
      '6!5':'6',      
      '6!11':'6',
      '7!4':'7',
      '7!5':'7',
      '8!2':'7,5H',
      '8!3':'8',
      '8!4':'8',
      '8!5':'8',
      '8!6':'ОТ01' ,
      '8!7':'8',
      '8!11':'7,5Н',
      '8!14':'8',
      '8!15':'7,5H',
      '8!16':'8',
      '8!18':'8',
      '9!3':'9',
      '10!3':'10',
      '10!5':'10',
      '11!3':'11ДВ',
      '12!3':'12',
      '12!4':'12',
      '12!5':'12',
      '12!6':'12',
      '12!10':'*',
      '12!11':'12',
      '12!15':'12',
      '12!16':'12',
      '12!18':'12',
      '-12!19':'МП',
      '-24!19':'МП'
    }
w = ''

SO = True # if True skip OT
#SO = False
for i in range(len(workers)):
    w = workers[i]
    #print(workers[i])
    for j in range(len(kdata[i])):
        day = mydata[i][j]
        s = km.get(day, '***')
        if s != kdata[i][j]:
            if w != '':
                print(w)
                w = ''        
            if s == '***':
                print('day =', str(j+1).rjust(2) , 'ГР =', day, 'km = ', mydata[i][j])
            else:
                if s != kdata[i][j]:
                    kms = kdata[i][j]
                    #print('***', s)
                    if kms.find('ОТ') != -1:
                        #print('find ot')
                        d1, d2 = day.split('!')
                        if (d2 == '6') and SO:
                            continue
                        #if SO:
                        print('day = ОТ', str(j+1).rjust(2), 'ГР =', s,'(', mydata[i][j], '), ЕКСУТР =', kdata[i][j])
                        
                    else:
                        print('day =', str(j+1).rjust(2), 'ГР =', s,'(', mydata[i][j], '), ЕКСУТР =', kdata[i][j])
    


    
