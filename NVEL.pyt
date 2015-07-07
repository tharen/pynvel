#NVEL.pyt

"""
Python toolbox for esitimating tree volume using the National Volume 
    Estimator Library (NVEL)
    
Author: Tod Haren, tharen@odf.state.or.us
Date: 2013/10/1

Notes:
    Works with ArcGIS 10.1 and Python 2.7
    Assumes the nvel.py wrapper module is in the same directory
"""

import arcpy
import nvel

class Toolbox(object):
    def __init__(self):
        """
        Tools for processing treelists with NVEL
        """
        self.label = "NVEL Tools"
        self.alias = ""

        # List of tool classes associated with this toolbox
        self.tools = [CalcTreeVolume]


class CalcTreeVolume(object):
    def __init__(self):
        """
        Calculate tree volume and update an attribute field.
        """
        self.label = "Calculate Tree Volume"
        self.description = "Calculates tree volume from species, dbh, and height."
        self.canRunInBackground = False

    def getParameterInfo(self):
        """Define parameter definitions"""

        trees_table = arcpy.Parameter(
                displayName='Tree Data Table'
                , name='trees_table'
                , datatype='GPTableView'
                , parameterType='Required'
                , direction='Input')
        trees_table.value = 'trees'

        spp_fld = arcpy.Parameter(
                displayName='Species Field'
                , name='spp_field'
                , datatype='Field'
                , parameterType='Required'
                , direction='Input')
        spp_fld.parameterDependencies = [trees_table.name]
        spp_fld.filter.list = ['Text']
        spp_fld.value = 'species'

        dbh_fld = arcpy.Parameter(
                displayName='DBH Field'
                , name='dbh_field'
                , datatype='Field'
                , parameterType='Required'
                , direction='Input')
        dbh_fld.parameterDependencies = [trees_table.name]
        dbh_fld.filter.list = ['Short', 'Long', 'Float', 'Double']
        dbh_fld.value = 'dbh'

        merch_ht_fld = arcpy.Parameter(
                displayName='Merch. Ht. Field'
                , name='merch_ht_field'
                , datatype='Field'
                , parameterType='Optional'
                , direction='Input')
        merch_ht_fld.parameterDependencies = [trees_table.name]
        merch_ht_fld.filter.list = ['Short', 'Long', 'Float', 'Double']
        merch_ht_fld.value = 'merch_ht'

        tot_ht_fld = arcpy.Parameter(
                displayName='Total Ht. Field'
                , name='tot_ht_field'
                , datatype='Field'
                , parameterType='Required'
                , direction='Input')
        tot_ht_fld.parameterDependencies = [trees_table.name]
        tot_ht_fld.filter.list = ['Short', 'Long', 'Float', 'Double']
        tot_ht_fld.value = 'total_ht'

        bdft_fld = arcpy.Parameter(
                displayName='Gross (merchantable) Board Ft. Volume Field'
                , name='bdft_field'
                , datatype='Field'
                , parameterType='Optional'
                , direction='Input')
        bdft_fld.parameterDependencies = [trees_table.name]
        bdft_fld.filter.list = ['Short', 'Long', 'Float', 'Double']
        bdft_fld.value = 'bdft_vol'

        cuft_fld = arcpy.Parameter(
                displayName='Gross (merchantable) Cubic Ft. Vol. Field'
                , name='cuft_field'
                , datatype='Field'
                , parameterType='Optional'
                , direction='Input')
        cuft_fld.parameterDependencies = [trees_table.name]
        cuft_fld.filter.list = ['Short', 'Long', 'Float', 'Double']
        cuft_fld.value = 'cuft_vol'

        tot_cuft_fld = arcpy.Parameter(
                displayName='Total Tree Cubic Ft. Vol. Field'
                , name='tot_cuft_field'
                , datatype='Field'
                , parameterType='Optional'
                , direction='Input')
        tot_cuft_fld.parameterDependencies = [trees_table.name]
        tot_cuft_fld.filter.list = ['Short', 'Long', 'Float', 'Double']
        tot_cuft_fld.value = 'total_vol'

## FIXME: ValueTables do not currently support filter lists.  Without filters
##            their usability is limited.  ArcGIS 10.2.1 will include filters.
#        field_map = arcpy.Parameter(
#                displayName='Output Field Map'
#                , name='out_field_map'
#                , datatype='GPValueTable'
#                , parameterType='Required'
#                , direction='Input')
#        field_map.columns = [['Field', 'Field Name'], ['GPString', 'NVEL Attribute']]
#        field_map.parameterDependencies = [trees_table.name]

        params = [trees_table, spp_fld, dbh_fld, merch_ht_fld, tot_ht_fld
                , bdft_fld, cuft_fld, tot_cuft_fld]

        return params

    def isLicensed(self):
        """Set whether tool is licensed to execute."""
        return True

    def updateParameters(self, parameters):
        """Modify the values and properties of parameters before internal
        validation is performed.  This method is called whenever a parameter
        has been changed."""
        return

    def updateMessages(self, parameters):
        """Modify the messages created by internal validation for each tool
        parameter.  This method is called after internal validation."""
        return

    def execute(self, parameters, messages):
        """The source code of the tool."""

        #zip the parameter names and values into a dictionary
        # {param:value,}
        params = dict(zip([p.name for p in parameters]
                , [p.valueAsText for p in parameters]))

        cur = arcpy.UpdateCursor(params['trees_table'])
        spp_fld = params['spp_field']
        dbh_fld = params['dbh_field']
        tot_ht_fld = params['tot_ht_field']
        m_ht_field = params['merch_ht_field']
        bdft_fld = params['bdft_field']
        cuft_fld = params['cuft_field']
        total_fld = params['tot_cuft_field']

        rec_count = int(arcpy.GetCount_management(params['trees_table']).getOutput(0))
        arcpy.SetProgressor("step", "Computing tree volumes..."
                , 0, rec_count, 1)
        #loop through each row in the table and compute the volumes
        for row in cur:
            spp = row.getValue(spp_fld)
            dbh = row.getValue(dbh_fld)
            tot_ht = row.getValue(tot_ht_fld)

            if spp and dbh and tot_ht:
                try:
                    vol = nvel.get_volume(dbh, tot_ht=tot_ht, spp=spp)
                    bdft = vol['gross_bdft']
                    cuft = vol['gross_cuft']
                    tot = vol['total_cuft']

                except:
                    bdft = None
                    cuft = None
                    tot = None

            else:
                bdft = None
                cuft = None
                tot = None

            #don't attempt to update fields that are not provided
            if bdft_fld:
                row.setValue(bdft_fld, bdft)

            if cuft_fld:
                row.setValue(cuft_fld, cuft)

            if total_fld:
                row.setValue(total_fld, tot)

            cur.updateRow(row)
            arcpy.SetProgressorPosition()

        arcpy.ResetProgressor()
