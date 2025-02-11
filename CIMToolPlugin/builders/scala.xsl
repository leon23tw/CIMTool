<?xml version="1.0" encoding="UTF-8"?>
<!--
  Copyright 2024 UCAIug

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

  See the License for the specific language governing permissions and
  limitations under the License.
-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:a="http://langdale.com.au/2005/Message#"
	xmlns:sawsdl="http://www.w3.org/ns/sawsdl"
	xmlns="http://langdale.com.au/2009/Indent">

	<xsl:output indent="yes" method="xml" encoding="utf-8" />
	<xsl:param name="version"/>
	<xsl:param name="baseURI"/>
	<xsl:param name="envelope">Profile</xsl:param>
	<xsl:param name="package">au.com.langdale.skena.vocabulary</xsl:param>
	
	<xsl:param name="mridType">String</xsl:param>

	<xsl:template name="type">
		<xsl:choose>
			<xsl:when test="@xstype = 'string'">String</xsl:when>
			<xsl:when test="@xstype = 'integer' or @xstype = 'int'">Int</xsl:when>
			<xsl:when test="@xstype = 'float'">Double</xsl:when>
			<xsl:when test="@xstype = 'double'">Double</xsl:when>
			<xsl:when test="@xstype = 'boolean'">Boolean</xsl:when>
			<xsl:otherwise>String</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="functional">
	  <xsl:if test="@maxOccurs &lt;= 1">Functional</xsl:if>
        </xsl:template>
        
	<xsl:template match="a:Catalog">
		<!--  the top level template  -->
		<document>
		    <item>package <xsl:value-of select="$package"/>;</item>
		    <item>import au.com.langdale.skena._</item>
		    <list begin="/**" indent=" * " end=" */">
			<item>API for <xsl:value-of select="$envelope" /></item>
			<item>Generated by CIMTool https://cimtool.ucaiug.io</item>
		    </list>
		    <item>object `<xsl:value-of select="$envelope" />` extends Vocabulary</item>
		    <list begin="{{" indent="    " end="}}">
		    	<xsl:apply-templates/>
		    </list>
		</document>
	</xsl:template>

	<xsl:template match="a:ComplexType|a:Root|a:CompoundType">
                <xsl:call-template name="annotate" />
		<item>object `<xsl:value-of select="@name"/>` extends Class( "<xsl:value-of select="@name"/>", "<xsl:value-of select="@baseClass"/>" )</item>
		<list begin="{{" indent="    " end="}}"> 
		    <xsl:apply-templates/>
		</list>
	</xsl:template>
	
	<xsl:template match="a:EnumeratedType">
		<sp/>
                <xsl:call-template name="annotate" />
		<item>object `<xsl:value-of select="@name"/>` extends OneOf( "<xsl:value-of select="@name"/>", "<xsl:value-of select="@baseClass"/>" )</item>
		<list begin="{{" indent="    " end="}};">
		    <xsl:apply-templates/>
		</list>
	</xsl:template>
        
        <xsl:template match="a:EnumeratedValue">
                <decorate>
                        <xsl:call-template name="annotate" />
                        <item>object `<xsl:value-of select="@name"/>` extends Individual( "<xsl:value-of select="@name"/>", "<xsl:value-of select="@baseResource"/>" )</item>
                </decorate>
        </xsl:template>

	<xsl:template match="a:Instance|a:Reference|a:Enumerated">
		<decorate>
			<xsl:call-template name="annotate" />
                        <item>object `<xsl:value-of select="@name"/>` extends <xsl:call-template name="functional"/>ObjectProperty( "<xsl:value-of select="@name"/>", "<xsl:value-of select="@baseProperty"/>" )</item>
		</decorate>
	</xsl:template>

	<xsl:template match="a:Simple|a:Domain">
		<decorate>
			<xsl:call-template name="annotate" />
                        <item>object `<xsl:value-of select="@name"/>` extends <xsl:call-template name="functional"/>DataProperty[<xsl:call-template name="type"/>]( "<xsl:value-of select="@name"/>", "<xsl:value-of select="@baseProperty"/>", "<xsl:value-of select="@xstype"/>" )</item>
		</decorate>
	</xsl:template>

	<xsl:template name="annotate">
		<!--  generate and annotation -->
		<list begin="/**" indent=" * " end=" */">
			<xsl:apply-templates mode="annotate"/>
		</list>
	</xsl:template>

	<xsl:template match="a:Comment|a:Note" mode="annotate">
		<!--  generate human readable annotation -->
		<wrap width="70">
			<xsl:value-of select="."/>
		</wrap>
	</xsl:template>

	<xsl:template match="text()">
		<!--  dont pass text through  -->
	</xsl:template>

	<xsl:template match="node()" mode="config">
		<!-- dont pass any defaults in config mode -->
	</xsl:template>

	<xsl:template match="node()" mode="annotate">
		<!-- dont pass any defaults in annotate mode -->
	</xsl:template>

</xsl:stylesheet>
