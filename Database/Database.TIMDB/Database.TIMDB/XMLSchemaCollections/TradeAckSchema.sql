CREATE XML SCHEMA COLLECTION [dbo].[TradeAckSchema]
    AS N'<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:t="http://www.develop.com/DMBrokerage/schemas/tradeAck" targetNamespace="http://www.develop.com/DMBrokerage/schemas/tradeAck">
  <xsd:complexType name="tradeAck">
    <xsd:complexContent>
      <xsd:restriction base="xsd:anyType">
        <xsd:sequence>
          <xsd:element name="OrderID" type="xsd:int" />
          <xsd:element name="AckId" type="xsd:int" />
        </xsd:sequence>
      </xsd:restriction>
    </xsd:complexContent>
  </xsd:complexType>
</xsd:schema>';

