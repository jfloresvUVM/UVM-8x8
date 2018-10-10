@isTest
public class JSON2apexTest {
	//metodo que comprueba el metodo parse en la calse json2apex
	@isTest static void testParse(){
		//se envia una cadena de texto con formato json para testear el funcionamiento de json2apex.parse
		JSON2Apex.parse('[{"id":"241534135","name":"test","Status":"close","opp":"1"}]');
	}
}