package com.kpm.reporter.excel
{
	
	public class Legend
	{
		public var legend : XML;
		public var smallLegend : XML;
	
		 
		public function Legend()
		{
			legend = <Worksheet Name="Legend">
    <Table ExpandedColumnCount="28" ExpandedRowCount="14" FullColumns="1" FullRows="1" DefaultColumnWidth="14">
      <Row>
           <Cell Index="2"><Data Type="String"> Legend : </Data></Cell>
      </Row>
      
      <Row><Cell> </Cell></Row>
     <Row>
    <Cell StyleID="Passed/Inactive"><Data Type="String">P</Data></Cell>
    <Cell Index="2"><Data Type="String"> the user has (most recently) passed this activity : even if they failed several times, now they have passed it. </Data></Cell>
    </Row>
    <Row>
    <Cell StyleID="Enjoy/Inactive"><Data Type="String">E</Data></Cell>
    <Cell Index="2"><Data Type="String">The user is “enjoying” the activity : the last time they played it, their score was between passing and failing.</Data></Cell>
   </Row>
   <Row>
    <Cell StyleID="Failed/Inactive"><Data Type="String">F</Data></Cell>
    <Cell Index="2"><Data Type="String">The user failed the activity the last time they played it.</Data></Cell>
   </Row>
    <Row>
   <Cell StyleID="defaultBubbleCell"><Data Type="String"></Data></Cell>
    <Cell Index="2"><Data Type="String">Clear box - the user has not played this activity.</Data></Cell>
   </Row>
   <Row>
   <Cell StyleID="NotPlayed/Active"><Data Type="String"></Data></Cell>
    <Cell Index="2"><Data Type="String">Bold box -- Could be presented to user</Data></Cell>
   </Row>   
   <Row>
    <Cell StyleID="NotPlayed/Inactive"><Data Type="String"></Data></Cell>
    <Cell Index="2"><Data Type="String">Not bold -- Will not be presented to user right now</Data></Cell>
   </Row>

   <Row><Cell> </Cell></Row>
   </Table>
     <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
      <PageSetup>
        <Layout Orientation="Landscape"/>
      </PageSetup>
      <Print>
        <ValidPrinterInfo/>
        <HorizontalResolution>-4</HorizontalResolution>
        <VerticalResolution>-4</VerticalResolution>
      </Print>
      <Selected/>
      <Panes>
        <Pane>
          <Number>3</Number>
          <ActiveRow>0</ActiveRow>
          <ActiveCol>0</ActiveCol>
        </Pane>
      </Panes>
      <ProtectObjects>False</ProtectObjects>
      <ProtectScenarios>False</ProtectScenarios>
      <ShowPageLayoutZoom/>
      <PageLayoutZoom>100</PageLayoutZoom>
    </WorksheetOptions>
   </Worksheet>;
   
   		smallLegend = 
   		<Row Index="26">
   		<Cell><Data Type="String">Legend : Green  – passed        Yellow – enjoying        Red –  failed        Bold – could be played        Not bold – can't be played</Data></Cell>
      	</Row>
		}

	}
}