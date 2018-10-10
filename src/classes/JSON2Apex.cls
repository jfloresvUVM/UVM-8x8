public class JSON2Apex {

	public String id;
	public String name;
	public String status;
	public Integer opp;

	
	public static List<JSON2Apex> parse(String json) {
		return (List<JSON2Apex>) System.JSON.deserialize(json, List<JSON2Apex>.class);
	}
}