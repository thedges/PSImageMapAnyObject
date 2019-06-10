global with sharing class PSImageMapAnyObjectController {
    public PSImageMapAnyObjectController() {

    }

    @AuraEnabled
    global static String getAreas(String sobjectName, String titleField, String idField, String shapeField, String coordsField, String detailsField, String whereClause)
    {
        try
        {
            String soqlStr = 'SELECT ' + titleField + ', ' + idField + ', ' + shapeField + ', ' + coordsField + ', ' + detailsField + '\r\n' +
                             '  FROM ' + sobjectName + '\r\n' +
                             ' WHERE ' + coordsField + ' != null';
            if (whereClause != null && whereClause.length() > 0)
            {
                soqlStr +=   ' AND ' + whereClause;
            }                 

            System.debug('soqlStr=' + soqlStr);
            
            List<SObject> objList = Database.query(soqlStr);

            List<Map<String, Object>> areas = new List<Map<String, Object>>();
            for (SObject obj : objList)
            {
                Map<String, Object> area = new Map<String, Object>();
                area.put('title', obj.get(titleField));
                area.put('shape', obj.get(shapeField));
                area.put('coords', obj.get(coordsField));
                area.put('id', obj.get(idField));
                area.put('details', obj.get(detailsField));
                areas.add(area);
            }

            return JSON.serialize(areas);
        }
        catch (Exception e)
        {
            throw new AuraHandledException(e.getTypeName() + ' - ' + e.getMessage() + ' [Line: ' + e.getLineNumber() + ']');
        }

    }
}