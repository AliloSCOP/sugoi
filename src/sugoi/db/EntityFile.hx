package sugoi.db;
import sys.db.Types;

/**
 *  EntityFile utility :
    Manage files linked to entities
 */
@:index(fileId,entityType,entityId)
class EntityFile extends sys.db.Object
{
    public var id:SId;
	@:relation(fileId) public var file : sugoi.db.File;
	public var entityType : SString<64>;
    public var documentType : SString<64>;
    public var data : SNull<SString<128>>;
    public var entityId : SInt;
	
	public function new(){
		super();
	}
	
	/**
		Get files linked to an entity
	**/
	public static function getByEntity(type:String,id:Int,?documentType:String){
        if(documentType==null){
            return Lambda.array(manager.search($entityId==id && $entityType==type,false));
        }else{
            return Lambda.array(manager.search($entityId==id && $entityType==type && $documentType==documentType, false));
        }
		
	}

	public static function make(type:String,id:Int,documentType:String,file:sugoi.db.File){
		var f = new EntityFile();
        f.entityId = id;
        f.entityType = type;
        f.documentType = documentType;
        f.file = file;
        f.insert();
        return f;
	}
	
}