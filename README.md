# SFI_ReferAttributesForPricing
Refer attributes for Attribute Based Pricing


Attribute Based Pricing framework provides capabilities to price a product instance based on the attribute values.
Limitation to this framework is, attributes which are required for pricing should be part of the respective product instance.
Ex: Iphone product price depends on Storage, Color and Contract Term. There is a difference in price depending on the Contract Term of plan 12M , 36M or 48M. So to price an Iphone all these attributes should be modeled in the Iphone product even though the user selects Contract Term in the plan level. To achieve this usually we create a duplicate attribute Contract Term in an IPhone product and copy this attribute value from the Parent Plan.

What if Attribute Based Pricing can price based on Attributes which are not part of the respective product? But referred in runtime from related product instances.

