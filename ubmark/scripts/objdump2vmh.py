import re
import sys
import fileinput

__hexre = '[0-9a-fA-F]'
__hexvre = __hexre + '+'
__hex8re = __hexre + '{8}'
__secheadre = '^Contents of section (?P<section>[\.\w]+):$'
__linere = '^\s*(?P<addr>' + __hexvre + ')' + \
        '\s*(?P<v0>' + __hex8re + ')(?=\s)' + \
        '\s*(?P<v1>' + __hex8re + ')?(?=\s)' + \
        '\s*(?P<v2>' + __hex8re + ')?(?=\s)' + \
        '\s*(?P<v3>' + __hex8re + ')?(?=\s)'

__bootstrapstr = '''
@20000
00001137
fff10113
0000d1b7
23818193
e99ff06f'''

def main():
    state = 'init'
    scp = re.compile(__secheadre)
    lp = re.compile(__linere)

    # print   __bootstrapstr # Moved to convert script.

    for line in fileinput.input():
        line = line.rstrip()

        m = scp.match(line)
        if m:
            state = 'init'
            print   ''
            continue

        m = lp.match(line)
        if m:
            if state == 'init':
                print   '@{0:x}'.format(int(m.group('addr'), 16)/4)
            state = 'in-section'
            for v in m.group('v0', 'v1', 'v2', 'v3'):
                if v:
                    print   v[6:8]+v[4:6]+v[2:4]+v[0:2]
            continue

if __name__ == '__main__':
    main()
