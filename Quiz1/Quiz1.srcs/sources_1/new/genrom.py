with open('bin2dec.data', 'w') as f:
    for i in range(2**14-1):
        a = i // 1000
        b = (i // 100) % 10
        c = (i // 10) % 10
        d = i % 10

        a = bin(a)[2:].rjust(4,'0')
        b = bin(b)[2:].rjust(4,'0')
        c = bin(c)[2:].rjust(4,'0')
        d = bin(d)[2:].rjust(4,'0')
        s = a+b+c+d
        f.write(s+'\n')