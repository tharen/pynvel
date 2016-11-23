
import sys
import string
import pyodbc
import pandas as pd

from pynvel import behres

dsn = ';'.join((
        'driver={{microsoft access driver (*.mdb, *.accdb)}}'
        , 'dbq={db_path}'))

db_path = r'C:\workspace\yield_tables\tl_superace\2013\Firebreak2\temporary.mdb'

conn = pyodbc.connect(dsn.format(**locals()))

sql = 'select * from TSPCVOL'
spcvol = pd.read_sql(sql, conn)
spcvol.columns = [c.lower() for c in spcvol.columns]
conn.close()

tdf = {a:float(i + 1) for i, a in enumerate(string.ascii_uppercase)}
tdf.update({i:i * .1 for i in range(10)})

spcvol['tot_cuft_t'] = 0.0
spcvol['merch_cuft_t'] = 0.0
spcvol['error_codes'] = ''
spcvol['b0'] = 0.0
spcvol['b1'] = 0.0

for r, row in spcvol.iterrows():
    td = tdf[row['tdf'].upper()] * row['bark']

    b = behres.BehresHyperbola(
            dbh=row['d4h'], total_ht=row['compheight']
            , form_class=row['formfactor'], form_ht=17.3
            , b1=1.0 - row['asubo'], bark_ratio=row['bark']
            , merch_ht=row['mrchheight'], merch_dib=td)

    spcvol.loc[r, 'tot_cuft_t'] = b.cuft()
    spcvol.loc[r, 'merch_cuft_t'] = b.merch_cuft(top_dib=td)
    spcvol.loc[r, 'b0'] = b.b0
    spcvol.loc[r, 'b1'] = b.b1

    if b.error_codes:
        print('Tree {} has errors, {}'.format(r, str(b.error_codes)))
        spcvol.loc[r, 'error_codes'] = ','.join(str(e) for e in b.error_codes)

cols = ['plotno', 'treeno', 'gradecount', 'prsmvalue', 'species', 'treecount', 'd4h'
        , 'formfactor', 'tdf', 'bolelength', 'tot height', 'compheight', 'mrchheight'
        , 'bdftscale', 'cuftrule', 'asubo', 'bark', 'tpa', 'gross cuft', 'net cuft'
        , 'tot_cuft_t', 'merch_cuft_t', 'plotadj', 'acres', 'plots'
        , 'b0', 'b1']
spcvol[cols].to_csv('c:/temp/behres_vol.csv')
