//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

// Generated from: MySchema.proto
namespace MyDtoLayer
{
  [global::System.Serializable, global::ProtoBuf.ProtoContract(Name=@"Customer")]
  public partial class Customer : global::ProtoBuf.IExtensible
  {
    public Customer() {}
    
    private int _id;
    [global::ProtoBuf.ProtoMember(1, IsRequired = true, Name=@"id", DataFormat = global::ProtoBuf.DataFormat.TwosComplement)]
    public int id
    {
      get { return _id; }
      set { _id = value; }
    }
    private string _name;
    [global::ProtoBuf.ProtoMember(2, IsRequired = true, Name=@"name", DataFormat = global::ProtoBuf.DataFormat.Default)]
    public string name
    {
      get { return _name; }
      set { _name = value; }
    }

    private Address _address = null;
    [global::ProtoBuf.ProtoMember(3, IsRequired = false, Name=@"address", DataFormat = global::ProtoBuf.DataFormat.Default)]
    [global::System.ComponentModel.DefaultValue(null)]
    public Address address
    {
      get { return _address; }
      set { _address = value; }
    }
    private global::ProtoBuf.IExtension extensionObject;
    global::ProtoBuf.IExtension global::ProtoBuf.IExtensible.GetExtensionObject(bool createIfMissing)
      { return global::ProtoBuf.Extensible.GetExtensionObject(ref extensionObject, createIfMissing); }
  }
  
  [global::System.Serializable, global::ProtoBuf.ProtoContract(Name=@"Address")]
  public partial class Address : global::ProtoBuf.IExtensible
  {
    public Address() {}
    
    private string _line1;
    [global::ProtoBuf.ProtoMember(1, IsRequired = true, Name=@"line1", DataFormat = global::ProtoBuf.DataFormat.Default)]
    public string line1
    {
      get { return _line1; }
      set { _line1 = value; }
    }

    private string _line2 = "";
    [global::ProtoBuf.ProtoMember(2, IsRequired = false, Name=@"line2", DataFormat = global::ProtoBuf.DataFormat.Default)]
    [global::System.ComponentModel.DefaultValue("")]
    public string line2
    {
      get { return _line2; }
      set { _line2 = value; }
    }

    private string _zip = "";
    [global::ProtoBuf.ProtoMember(7, IsRequired = false, Name=@"zip", DataFormat = global::ProtoBuf.DataFormat.Default)]
    [global::System.ComponentModel.DefaultValue("")]
    public string zip
    {
      get { return _zip; }
      set { _zip = value; }
    }
    private global::ProtoBuf.IExtension extensionObject;
    global::ProtoBuf.IExtension global::ProtoBuf.IExtensible.GetExtensionObject(bool createIfMissing)
      { return global::ProtoBuf.Extensible.GetExtensionObject(ref extensionObject, createIfMissing); }
  }
  
  [global::System.Serializable, global::ProtoBuf.ProtoContract(Name=@"GetCustomerRequest")]
  public partial class GetCustomerRequest : global::ProtoBuf.IExtensible
  {
    public GetCustomerRequest() {}
    
    private int _id;
    [global::ProtoBuf.ProtoMember(1, IsRequired = true, Name=@"id", DataFormat = global::ProtoBuf.DataFormat.TwosComplement)]
    public int id
    {
      get { return _id; }
      set { _id = value; }
    }
    private global::ProtoBuf.IExtension extensionObject;
    global::ProtoBuf.IExtension global::ProtoBuf.IExtensible.GetExtensionObject(bool createIfMissing)
      { return global::ProtoBuf.Extensible.GetExtensionObject(ref extensionObject, createIfMissing); }
  }
  
  [global::System.Serializable, global::ProtoBuf.ProtoContract(Name=@"GetCustomerResponse")]
  public partial class GetCustomerResponse : global::ProtoBuf.IExtensible
  {
    public GetCustomerResponse() {}
    

    private Customer _cust = null;
    [global::ProtoBuf.ProtoMember(1, IsRequired = false, Name=@"cust", DataFormat = global::ProtoBuf.DataFormat.Default)]
    [global::System.ComponentModel.DefaultValue(null)]
    public Customer cust
    {
      get { return _cust; }
      set { _cust = value; }
    }
    private global::ProtoBuf.IExtension extensionObject;
    global::ProtoBuf.IExtension global::ProtoBuf.IExtensible.GetExtensionObject(bool createIfMissing)
      { return global::ProtoBuf.Extensible.GetExtensionObject(ref extensionObject, createIfMissing); }
  }
  
}
