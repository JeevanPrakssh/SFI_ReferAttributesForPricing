public class ReliesOnAttributeReferenceImpl implements vlocity_cmt.VlocityOpenInterface {
    public Boolean invokeMethod(String methodName, Map < String, Object > input, Map < String, Object > outMap, Map < String, Object > options) {
        try{
            if (methodName.equals('ReliesOnAttributeReferenceImpl')) {
                ReliesOnAttributeReferenceImpl(input,outMap, options);
            }
            return true;
        }
        catch(Exception e){
           System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }
    }
    public void ReliesOnAttributeReferenceImpl(Map < String, Object > input, Map < String, Object > outMap, Map < String, Object > options)
    {
        String scope ;
        String reltypescope;
        Id quoteId ;
        List<Id > lineItemIdlist = new List<Id>();
        List<Id>lineItemIdAll = new List<Id>();

        quoteId = (Id)input.get('ContextId');
        String idlistst =(String)input.get('RecordIds');

            if(idlistst!=null)
            {
                List<string> idlist = idlistst.split(',');
                
                if(idlist.size()>0)
                {
                    for(string s:idlist)
                    {
                        lineItemIdAll.add((Id)s);
                    } 
                    Id lineit = lineItemIdAll[0];
                    List<QuoteLineItem>  qlich= [select id from quotelineitem where id =: lineit ];
                    if(qlich.size() >0)
                    {
                        scope = 'Quote';
                        
                    }
                    else
                    {
                        scope = 'Order';
                        
                    }
                    
                } 
            }
        
        
            if(quoteId != null)
            {
                if(quoteId.getSObjectType().getDescribe().getName() == 'Quote')
                {
                    scope = 'Quote';       
                }
                else
                {
                   scope = 'Order';
                }
                
            }
        
        
        scope = 'Quote'; 
        if(scope == 'Quote')
        {
            
            List<vlocity_cmt__QuoteLineItemRelationship__c>existingqprel = [select id, vlocity_cmt__QuoteLineItemId__c, vlocity_cmt__RelatedQuoteLineItemId__c, 
                                                                            vlocity_cmt__RelationshipType__c,vlocity_cmt__RelatedAssetReferenceId__c ,
                                                                            vlocity_cmt__QuoteLineItemId__r.vlocity_cmt__Product2Id__c,vlocity_cmt__RelatedQuoteLineItemId__r.vlocity_cmt__Product2Id__c,vlocity_cmt__ProductRelationshipIdentifier__c FROM vlocity_cmt__QuoteLineItemRelationship__c 
                                                                            WHERE vlocity_cmt__QuoteId__c =: quoteid OR vlocity_cmt__QuoteLineItemId__c in:lineItemIdAll];
            set<id> sourceproductid = new set<id>();
            set<id> prprodlist = new set<id>();
            set<string> assetreflist = new set<String>();
            set<id>sourcequoteidlist = new set<id>();
            Map<string,vlocity_cmt__ProductRelationship__c> prrelmap = new Map<string,vlocity_cmt__ProductRelationship__c>();
            Map<id,string> prreltypemap = new Map<id,string>();
            if(vlocity_cmt__QuoteLineItemRelationship__c.sObjectType.getDescribe().IsAccessible() )
            {
                if(existingqprel.size()>0)
                {
                    for(vlocity_cmt__QuoteLineItemRelationship__c qlir : existingqprel)
                    {
                        if(qlir.vlocity_cmt__QuoteLineItemId__c != null)
                        {
                            sourceproductid.add(qlir.vlocity_cmt__QuoteLineItemId__r.vlocity_cmt__Product2Id__c);
                            sourcequoteidlist.add(qlir.vlocity_cmt__QuoteLineItemId__c);
                        }
                        if(qlir.vlocity_cmt__RelatedAssetReferenceId__c != null)
                        {
                            assetreflist.add(qlir.vlocity_cmt__RelatedAssetReferenceId__c );
                        }
                        
                    }
                }
                Map<String,QuoteLineItem > qlimap = new Map<String,QuoteLineItem >();
                Map<id,QuoteLineItem > qlisourcemap = new Map<id,QuoteLineItem >([select id,vlocity_cmt__AttributeSelectedValues__c,vlocity_cmt__Product2Id__c,Pricing_Attributes__c from QuoteLineItem where id in:sourcequoteidlist]);
                // sorted by createddate so the latest instance will be stored in the map
                for(QuoteLineItem qli:[select id,Pricing_Attributes__c ,vlocity_cmt__AttributeSelectedValues__c,vlocity_cmt__Product2Id__c,vlocity_cmt__AssetReferenceId__c from QuoteLineItem where vlocity_cmt__AssetReferenceId__c in:assetreflist order by createddate ])
                {
                    qlimap.put(qli.vlocity_cmt__AssetReferenceId__c,qli);
                }
                Map<string,Asset> assetmap = new Map<string,Asset>();
                for(asset a:[select vlocity_cmt__AssetReferenceId__c,id, vlocity_cmt__AttributeSelectedValues__c,Product2Id  from asset where vlocity_cmt__AssetReferenceId__c in:assetreflist order by createddate ])
                {
                    assetmap.put(a.vlocity_cmt__AssetReferenceId__c,a);
                }
                Map<string,OrderItem> oimap = new Map<string,OrderItem>();
                for(OrderItem o:[select id, vlocity_cmt__AttributeSelectedValues__c,vlocity_cmt__AssetReferenceId__c,vlocity_cmt__Product2Id__c  from orderitem where vlocity_cmt__AssetReferenceId__c in:assetreflist order by createddate ])
                {
                    oimap.put(o.vlocity_cmt__AssetReferenceId__c,o);
                }
                if(vlocity_cmt__ProductRelationship__c.sObjectType.getDescribe().IsAccessible()){
                    for (vlocity_cmt__ProductRelationship__c   prList : [SELECT Id,Name,Product_Relationship_Type__r.Name, vlocity_cmt__Product2Id__c,vlocity_cmt__AttributeModificationContext__c,
                                                                         vlocity_cmt__RelatedProductId__c,vlocity_cmt__RelationshipType__c,vlocity_cmt__ActionParameters__c ,
                                                                         Product_Relationship_Type__r.vlocity_cmt__RelationshipTypeScope__c,Product_Relationship_Type__c 
                                                                         FROM vlocity_cmt__ProductRelationship__c 
                                                                         WHERE vlocity_cmt__Product2Id__c in :sourceproductid])
                    {
                        prreltypemap.put(prList.id,prList.Product_Relationship_Type__r.Name);
                        if(prList.vlocity_cmt__RelationshipType__c == 'Attribute Propagation/Reference' && prList.vlocity_cmt__AttributeModificationContext__c =='ReliesOn' && prList.vlocity_cmt__ActionParameters__c!=null)
                        {
                            String s = prList.vlocity_cmt__Product2Id__c + ':' + prList.vlocity_cmt__RelatedProductId__c ;
                            prprodlist.add(prList.vlocity_cmt__Product2Id__c);
                            prrelmap.put(s,prList);
                        }
                        
                    }
                }
                List<Id> qlilistup = new List<id>();
                Map<id,QuoteLineItem> qliattrimap = new Map<id,QuoteLineItem>();
                if(prprodlist.size()>0)
                {
                    for(vlocity_cmt__QuoteLineItemRelationship__c qlir :existingqprel)
                    {
                        if(prprodlist.contains(qlir.vlocity_cmt__QuoteLineItemId__r.vlocity_cmt__Product2Id__c))
                        {
                            QuoteLineItem qlsource = qlisourcemap.get(qlir.vlocity_cmt__QuoteLineItemId__c);
                            
                            if(qlir.vlocity_cmt__RelatedAssetReferenceId__c != null)
                            {
                                if(oimap.containsKey(qlir.vlocity_cmt__RelatedAssetReferenceId__c ))
                                {
                                    OrderItem oi = oimap.get(qlir.vlocity_cmt__RelatedAssetReferenceId__c);
                                    String s = qlsource.vlocity_cmt__Product2Id__c + ':' + oi.vlocity_cmt__Product2Id__c ;
                                    if(prrelmap.containsKey(s))
                                    {
                                        vlocity_cmt__ProductRelationship__c Prrel = prrelmap.get(s);
                                        string sumrefer;
                                        string referatt;
                                        string totalparam = actionparamatersmanipulate(Prrel.vlocity_cmt__ActionParameters__c);
                                        referatt = totalparam.split(';')[0];
                                        sumrefer =totalparam.split(';')[1];
                                        Integer k=0;
                                        if(qliattrimap.containskey(qlsource.id))
                                        {
                                            k=1;
                                        }
                                        String a = modifyAttributes(qlsource.vlocity_cmt__AttributeSelectedValues__c,oi.vlocity_cmt__AttributeSelectedValues__c,qlsource.Pricing_Attributes__c,referatt,sumrefer,k);
                                        
                                        if(a!=null)
                                        {
                                            qlsource.Pricing_Attributes__c =a;  
                                        }
                                        qlilistup.add(qlsource.id);
                                        qliattrimap.put(qlsource.id,qlsource);
                                        
                                    }
                                }
                                else if(qlimap.containsKey(qlir.vlocity_cmt__RelatedAssetReferenceId__c))
                                {
                                    QuoteLineItem qlrel = qlimap.get(qlir.vlocity_cmt__RelatedAssetReferenceId__c);
                                    String s = qlsource.vlocity_cmt__Product2Id__c + ':' + qlrel.vlocity_cmt__Product2Id__c ;
                                    if(prrelmap.containsKey(s))
                                    {
                                        vlocity_cmt__ProductRelationship__c Prrel = prrelmap.get(s);
                                        string sumrefer;
                                        string referatt;
                                        string totalparam = actionparamatersmanipulate(Prrel.vlocity_cmt__ActionParameters__c);
                                        referatt = totalparam.split(';')[0];
                                        sumrefer = totalparam.split(';')[1];       
                                        Integer k=0;
                                        if(qliattrimap.containskey(qlsource.id))
                                        {
                                            k=1;
                                        }
                                        String a = modifyAttributes(qlsource.vlocity_cmt__AttributeSelectedValues__c,qlrel.vlocity_cmt__AttributeSelectedValues__c,qlsource.Pricing_Attributes__c,referatt,sumrefer,k);
                                        
                                        if(a!=null)
                                        {
                                            qlsource.Pricing_Attributes__c =a  ;
                                        }
                                        qlilistup.add(qlsource.id);
                                        qliattrimap.put(qlsource.id,qlsource);
                                        
                                    }
                                }
                                
                                else if(assetmap.containsKey(qlir.vlocity_cmt__RelatedAssetReferenceId__c))
                                {
                                    asset a = assetmap.get(qlir.vlocity_cmt__RelatedAssetReferenceId__c);
                                   String s = qlsource.vlocity_cmt__Product2Id__c + ':' + a.Product2Id ;
                                    if(prrelmap.containsKey(s))
                                    {
                                        vlocity_cmt__ProductRelationship__c Prrel = prrelmap.get(s);
                                        string sumrefer;
                                        string referatt;
                                        string totalparam = actionparamatersmanipulate(Prrel.vlocity_cmt__ActionParameters__c);
                                        referatt = totalparam.split(';')[0];
                                        sumrefer =totalparam.split(';')[1];
                                        Integer k=0;
                                        if(qliattrimap.containskey(qlsource.id))
                                        {
                                            k=1;
                                        }
                                        String ax = modifyAttributes(qlsource.vlocity_cmt__AttributeSelectedValues__c,a.vlocity_cmt__AttributeSelectedValues__c,qlsource.Pricing_Attributes__c,referatt,sumrefer,k);
                                        
                                        if(ax!=null)
                                        {
                                            qlsource.Pricing_Attributes__c =ax ; 
                                        }
                                        qlilistup.add(qlsource.id);
                                        qliattrimap.put(qlsource.id,qlsource);
                                        
                                    }
                                    
                                }
                            }
                            
                        }      
                    }
                }
                
                Map<String,Object> outputmap = new Map<String,Object>();
                Map<String,Object> theObj = new Map<String, Object>();
                theObj.put('Scope',Scope);
                theObj.put('Records',qlilistup);
                
                Map<String,Object> theObj1 = new Map<String, Object>();
                theObj1.put('message','Attributes are updated successfully');
                List<Object>msglist =new List<Object>();
                msgList.add(theObj1);
                List<Object>recList =new List<Object>();
                recList.add(theObj);
                
                outputmap.put('totalSize', 1);
                outputmap.put('messages',msgList);
                outputmap.put('records',reclist);
                
                if(qliattrimap.size()>0)
                {
                    Database.update(qliattrimap.values());
                    outMap.put('Creation Status',json.serialize(outputmap));
                    
                }
            }
        }
        else if(Scope == 'Order')
        {
            List<vlocity_cmt__OrderItemRelationship__c >existingqprel = [select id, vlocity_cmt__OrderItemId__c , vlocity_cmt__RelatedOrderItemId__c , 
                                                                         vlocity_cmt__RelationshipType__c,vlocity_cmt__RelatedAssetReferenceId__c ,
                                                                         vlocity_cmt__OrderItemId__r.vlocity_cmt__Product2Id__c,vlocity_cmt__RelatedOrderItemId__r.vlocity_cmt__Product2Id__c,vlocity_cmt__ProductRelationshipIdentifier__c FROM vlocity_cmt__OrderItemRelationship__c  WHERE vlocity_cmt__OrderId__c  =: quoteid
                                                                         or vlocity_cmt__OrderItemId__c in:lineItemidall];
            set<id> sourceproductid = new set<id>(); 
            set<id> prprodlist = new set<id>();
            set<string> assetreflist = new set<String>();
            set<id>relorderidlist = new set<id>();
            set<id>sourceorderidlist = new set<id>();
            Map<string,vlocity_cmt__ProductRelationship__c> prrelmap = new Map<string,vlocity_cmt__ProductRelationship__c>();
            Map<id,string> prreltypemap = new Map<id,string>();
            if(vlocity_cmt__OrderItemRelationship__c.sObjectType.getDescribe().IsAccessible() )
            {
                
                for(vlocity_cmt__OrderItemRelationship__c qlir : existingqprel)
                {
                    
                    if(qlir.vlocity_cmt__OrderItemId__r.vlocity_cmt__Product2Id__c != null)
                    {
                        sourceproductid.add(qlir.vlocity_cmt__OrderItemId__r.vlocity_cmt__Product2Id__c);
                    }
                    if(qlir.vlocity_cmt__RelatedAssetReferenceId__c != null)
                    {
                        assetreflist.add(qlir.vlocity_cmt__RelatedAssetReferenceId__c );
                    }
                    if(qlir.vlocity_cmt__RelatedOrderItemId__c !=null)
                    {
                        relorderidlist.add(qlir.vlocity_cmt__RelatedOrderItemId__c); 
                    }
                    if(qlir.vlocity_cmt__OrderItemId__c !=null)
                    {
                        sourceorderidlist.add(qlir.vlocity_cmt__OrderItemId__c);
                    }
                }
            }
            Map<id,OrderItem > oisourcemap = new Map<id,OrderItem >( [select id,Pricing_Attributes__c,vlocity_cmt__AttributeSelectedValues__c,vlocity_cmt__Product2Id__c from OrderItem where (id in:relorderidlist or id in:sourceorderidlist)]);
            
            Map<String,OrderItem > oimap = new Map<string,OrderItem >();
            for(OrderItem oi : [select id,vlocity_cmt__AttributeSelectedValues__c,Pricing_Attributes__c,vlocity_cmt__Product2Id__c,vlocity_cmt__AssetReferenceId__c from OrderItem where vlocity_cmt__AssetReferenceId__c in:assetreflist])
            {
                oimap.put(oi.vlocity_cmt__AssetReferenceId__c,oi);
            }
            Map<string,Asset> assetmap = new Map<string,Asset>();
            for(asset a:[select vlocity_cmt__AssetReferenceId__c,id, vlocity_cmt__AttributeSelectedValues__c,Pricing_Attributes__c,Product2Id  from asset where vlocity_cmt__AssetReferenceId__c in:assetreflist])
            {
                assetmap.put(a.vlocity_cmt__AssetReferenceId__c,a);
            }
            if(vlocity_cmt__ProductRelationship__c.sObjectType.getDescribe().IsAccessible()){
                
                for (vlocity_cmt__ProductRelationship__c   prList : [SELECT Id,Name,Product_Relationship_Type__r.Name, vlocity_cmt__Product2Id__c,vlocity_cmt__AttributeModificationContext__c,
                                                                     vlocity_cmt__RelatedProductId__c,vlocity_cmt__RelationshipType__c,vlocity_cmt__ActionParameters__c ,
                                                                     Product_Relationship_Type__r.vlocity_cmt__RelationshipTypeScope__c,Product_Relationship_Type__c 
                                                                     FROM vlocity_cmt__ProductRelationship__c 
                                                                     WHERE vlocity_cmt__Product2Id__c in :sourceproductid])
                {
                    
                    prreltypemap.put(prList.id,prList.Product_Relationship_Type__r.Name);
                    if(prList.vlocity_cmt__RelationshipType__c == 'Attribute Propagation/Reference' && prList.vlocity_cmt__AttributeModificationContext__c =='ReliesOn' && prList.vlocity_cmt__ActionParameters__c!=null)
                    {
                        String s = prList.vlocity_cmt__Product2Id__c + ':' + prList.vlocity_cmt__RelatedProductId__c ;
                        prprodlist.add(prList.vlocity_cmt__Product2Id__c);
                        prrelmap.put(s,prList);
                        
                    }
                    
                }
            }
            
            List<id> qlilistup = new List<id>();
            Map<id,OrderItem> oiattrimap = new Map<id,OrderItem>();
            if(prprodlist.size()>0)
            {
                for(vlocity_cmt__OrderItemRelationship__c  qlir :existingqprel)
                {
                    if(prprodlist.contains(qlir.vlocity_cmt__OrderItemId__r.vlocity_cmt__Product2Id__c))
                    {
                        OrderItem qlsource = oisourcemap.get(qlir.vlocity_cmt__OrderItemId__c);
                        
                        if(qlir.vlocity_cmt__RelatedAssetReferenceId__c  != null)
                        {
                            if(oimap.containskey(qlir.vlocity_cmt__RelatedAssetReferenceId__c))
                            {
                                OrderItem qlrel = oimap.get(qlir.vlocity_cmt__RelatedAssetReferenceId__c);
                                
                                String s = qlsource.vlocity_cmt__Product2Id__c + ':' + qlrel.vlocity_cmt__Product2Id__c ;
                                
                                if(prrelmap.containsKey(s))
                                {
                                    vlocity_cmt__ProductRelationship__c Prrel = prrelmap.get(s);
                                    string sumrefer;
                                    string referatt;
                                    string totalparam = actionparamatersmanipulate(Prrel.vlocity_cmt__ActionParameters__c);
                                    referatt = totalparam.split(';')[0];
                                    sumrefer =totalparam.split(';')[1];
                                    Integer k=0;
                                    if(oiattrimap.containskey(qlsource.id))
                                    {
                                        k=1;
                                    }
                                    String a = modifyAttributes(qlsource.vlocity_cmt__AttributeSelectedValues__c,qlrel.vlocity_cmt__AttributeSelectedValues__c,qlsource.Pricing_Attributes__c,referatt,sumrefer,k);
                                    
                                    if(a!=null)
                                    {
                                        qlsource.Pricing_Attributes__c =a;
                                    }
                                    qlilistup.add(qlsource.id);
                                    oiattrimap.put(qlsource.id,qlsource);
                                    
                                }
                            }
                            else if(assetmap.containsKey(qlir.vlocity_cmt__RelatedAssetReferenceId__c))
                            {
                                asset a = assetmap.get(qlir.vlocity_cmt__RelatedAssetReferenceId__c);
                                String s = qlsource.vlocity_cmt__Product2Id__c + ':' + a.Product2Id ;
                                if(prrelmap.containsKey(s))
                                {
                                    vlocity_cmt__ProductRelationship__c Prrel = prrelmap.get(s);
                                    string sumrefer;
                                    string referatt;
                                    string totalparam = actionparamatersmanipulate(Prrel.vlocity_cmt__ActionParameters__c);
                                    
                                    referatt = totalparam.split(';')[0];
                                    sumrefer =totalparam.split(';')[1];                        
                                    Integer k=0;
                                    if(oiattrimap.containskey(qlsource.id))
                                    {
                                        k=1;
                                    }
                                    String ax = modifyAttributes(qlsource.vlocity_cmt__AttributeSelectedValues__c,a.vlocity_cmt__AttributeSelectedValues__c,qlsource.Pricing_Attributes__c,referatt,sumrefer,k);
                                    
                                    if(ax!=null)
                                    {
                                        qlsource.Pricing_Attributes__c =ax; 
                                    }
                                    qlilistup.add(qlsource.id);
                                    oiattrimap.put(qlsource.id,qlsource);
                                    
                                }
                                
                                
                            }
                        }
                    }      
                }
            }
            Map<String,Object> outputmap = new Map<String,Object>();
            Map<String,Object> theObj = new Map<String, Object>();
            theObj.put('Scope',Scope);
            theObj.put('Records',qlilistup);
            Map<String,Object> theObj1 = new Map<String, Object>();
            theObj1.put('message','Attributes are updated successfully');
            List<Object>msglist =new List<Object>();
            msgList.add(theObj1);
            List<Object>recList =new List<Object>();
            recList.add(theObj);
            outputmap.put('totalSize', 1);
            outputmap.put('messages',msgList);
            outputmap.put('records',reclist);
            if(oiattrimap.size()>0)
            {
                Database.update(oiattrimap.values());
                outputmap.put('Creation Status',json.serialize(outputmap));
            }
        }
        
        
    }
    public string actionparamatersmanipulate(string s)
    {
        string s4;
        string s5;
        string sumrefer=null;
        string referatt=null;
        if(s !=null)
        {
            s4 = s.substringafter('REFER(');
            
            if(s4.contains(',SUM('))
            {
                referatt = s4.substringbefore(',SUM(');
                s5= s.substringafter(',SUM(');
                sumrefer= s5.substringbefore(')');
            }
            else
            {
                referatt = s4.substringbefore(')');
            }
        }
        
        return referatt+';'+sumrefer;
    }
    public string modifyAttributes(String source,String target,String pricingatt,string referparam, string sumreferparam,Integer k)
    {
        Map<String, String> sourceMap = new Map<String, String>() ;
        Map<String, String> referMap = new Map<String, String>() ;
        Map<String, String> targetMap = new Map<String,String>();
        string jsonstring ;
        if(pricingatt != null)
        {
            referMap = (Map<String, String>) JSON.deserialize(pricingatt,Map<String, String>.class);
        }
        if(target !=null)
        {
            targetMap = (Map<String, String>) JSON.deserialize(target,Map<String, String>.class);
        }
        if(source !=null)
        {
            sourceMap = (Map<String, String>) JSON.deserialize(source,Map<String, String>.class);
        }
        try{        
            
            if(referparam!=null && target !=null)
            {
                List<String> paramlist = referparam.split(',');
                
                for(String s:paramlist)
                {
                    if(targetMap.containsKey(s))
                        
                    {  
                        String sourval = targetMap.get(s);
                        referMap.put(s,sourval);
                    }                   
                }
                
            }   
            if(sumreferparam!=null && target !=null )
            {
                List<String> paramlist = sumreferparam.split(',');
                for(String s:paramlist)
                {
                    
                    if(targetMap.containsKey(s))
                    {
                        
                        if(referMap.containsKey(s))
                        {
                            String tarval = targetMap.get(s);
                            
                            String sourval = referMap.get(s);
                            if(k==0)
                            {
                                sourval = '0';
                            }
                            
                            Decimal d;
                            if(tarval!=null && sourval!=null )
                                d= Decimal.valueOf(sourval) + Decimal.valueOf(tarval);
                            referMap.put(s,String.valueOf(d));
                            
                        }   
                        else
                        {
                            String tarval = targetMap.get(s);
                            Decimal d; 
                            if(tarval!=null)
                                d=  Decimal.valueOf(tarval);
                            referMap.put(s,String.valueOf(d));
                        }
                    }
                }
            }
            
            if(referMap!=null)
            {
                jsonstring = JSON.serialize(referMap);
            }
        }
        catch(Exception E){
            System.debug('The following exception has occurred: ' + e.getMessage());
           
        }
        return jsonstring;
        
    } 
}