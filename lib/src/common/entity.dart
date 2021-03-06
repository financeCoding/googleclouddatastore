part of datastore.common;

class Entity {
  Datastore _datastore;
  final Key key;
  Kind get kind => _datastore.kindByName(key.kind);
  final PropertyMap _properties;
  
  /**
   * Create a new [Entity] against the given [datastore]
   * with the given [key] and, optionally, initial values
   * for the entity's properties.
   */
  Entity(Datastore datastore, Key key, [Map<String,dynamic> propertyInits = const {}]) :
    this._datastore = datastore,
    this.key = key,
    _properties = new PropertyMap(datastore.kindByName(key.kind), propertyInits);
  
  dynamic getProperty(String propertyName) {
    var prop = _properties[propertyName];
    if (prop == null) {
      throw new NoSuchPropertyError(this, propertyName);
    }
    return prop.value;
  }
  
  void setProperty(String propertyName, var value) {
    var prop = _properties[propertyName];
    if (prop == null) {
      throw new NoSuchPropertyError(this, propertyName);
    }
    prop.value = value;
  }
  
  schema.Entity _toSchemaEntity() {
    schema.Entity schemaEntity = new schema.Entity();
    schemaEntity.key = key._toSchemaKey();
    _properties.forEach((String name, _PropertyInstance prop) {
      var defn = kind.properties[name];
      schemaEntity.property.add(prop._toSchemaProperty(defn));
    });  
    return schemaEntity;
  }
  
  bool operator ==(Object other) => other is Entity && other.key == key;
  int get hashCode => key.hashCode;
  
  String toString() => "Entity($key)";
}

/**
 * The result of a lookup operation for an [Entity].
 */
class EntityResult {
  /**
   * The looked up key
   */
  final Key key;
  /**
   * The entity found associated with the [:key:] in the datastore,
   * or `null` if no entity corresponding with the given key exists.
   */
  final Entity entity;
  
  /**
   * An entity was found for the provided [Key]
   */
  bool get hasResult => entity != null;
  
  EntityResult._(this.key, this.entity);
}

class PropertyMap extends UnmodifiableMapMixin<String,_PropertyInstance> {
  final Kind kind;
  Map<String,_PropertyInstance> _entityProperties;
  
  PropertyMap(Kind kind, Map<String,dynamic> propertyInits) :
    this.kind = kind,
    _entityProperties = new Map.fromIterable(
        kind.properties.values,
        key: (prop) => prop.name,
        value: (Property prop) => prop.type.create(initialValue: propertyInits[prop.name])
    );
  
  @override
  _PropertyInstance operator [](String key) => _entityProperties[key];

  @override
  bool containsKey(String key) => _entityProperties.containsKey(key);

  @override
  bool containsValue(_PropertyInstance value) => _entityProperties.containsValue(value);

  @override
  void forEach(void f(String key, _PropertyInstance value)) {
    _entityProperties.forEach(f);
  }

  @override
  bool get isEmpty => _entityProperties.isEmpty;

  @override
  bool get isNotEmpty => _entityProperties.isNotEmpty;

  @override
  Iterable<String> get keys => _entityProperties.keys;

  @override
  int get length => _entityProperties.length;

  @override
  Iterable<_PropertyInstance> get values => _entityProperties.values;
}
