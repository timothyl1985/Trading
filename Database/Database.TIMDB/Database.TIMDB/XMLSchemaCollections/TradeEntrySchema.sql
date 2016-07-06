CREATE XML SCHEMA COLLECTION [dbo].[TradeEntrySchema]
    AS N'<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" elementFormDefault="qualified">
  <xsd:element name="tradeEntry">
    <xsd:complexType>
      <xsd:complexContent>
        <xsd:restriction base="xsd:anyType">
          <xsd:sequence>
            <xsd:element name="RICCODE" type="xsd:string" />
            <xsd:element name="CustomerID" type="xsd:unsignedShort" />
            <xsd:element name="OrderID" type="xsd:unsignedShort" />
            <xsd:element name="Date" type="xsd:date" />
            <xsd:element name="BuySell" type="xsd:date" />
            <xsd:element name="Volume" type="xsd:unsignedShort" />
            <xsd:element name="Price" type="xsd:decimal" />
          </xsd:sequence>
        </xsd:restriction>
      </xsd:complexContent>
    </xsd:complexType>
  </xsd:element>
</xsd:schema>';

