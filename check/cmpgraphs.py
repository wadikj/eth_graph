
def load_dict(fname):
    with open(fname, encoding='utf-8') as fi:
        l = fi.readlines()
    
    while True:
        s = l[0].strip()
        if s != '#':
            l.pop(0)
        else:
            l.pop(0)
            break
    result = dict()
    for s in l:
        key, value = s.split('=')
        result[key] = value.strip()
    return result


f1 = 'm1'
f2 = 'm2'

d1 = load_dict(f1)
d2 = load_dict(f2)

print ('graphs loaded...')

if len(d1) != len(d2):
    print ('different workers count:', len(d1),'AND', len(d2))

workers = list(d1.keys())

for s in workers:
    sworker = 'worker: ' + s
    #print('worker:',s);
    days1 = d1.get(s,'')
    days2 = d2.get(s,'')
    if days1 == '':
        print(f'worker {s} not found in main graph')
        continue
    if days2 == '':
        print(f'worker {s} not found in compared graph')
        continue

    del(d1[s])
    del(d2[s])
    q1 = days1.split('|')
    q2 = days2.split('|')

    for i in range(1,len(q1)):
        if q1[i] != q2[i]:
            if sworker != '':
                print(sworker);
                sworker = ''
            print('Date:',str(i) + ', main='+q1[i]+ ', compared='+q2[i])


for s in d2.keys():
    print(s)
    print('worker not found in main graph')

    
    



        

    
        
