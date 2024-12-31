<%@page import="project.ConnectionProvider" %>
<%@page import="java.sql.*"%>
<%
String email=session.getAttribute("email").toString();
String product_id=request.getParameter("id");
int quantity=1;
int product_price=0;
int product_total=0;
int cart_total=0;

int z =0;
try{
	Connection con=ConnectionProvider.getCon();
	Statement st= con.createStatement();
	ResultSet rs= st.executeQuery("select *from product where id='"+product_id+"'");
	while(rs.next())
	{
		product_price=rs.getInt(4);  //4th value is for price thats why int
		product_total=product_price;
	}
	ResultSet rs1= st.executeQuery("select *from cart where product_id='"+product_id+"' and email='"+email+"' and address is NULL");
	// query to check if the product already exist in car
	while(rs1.next())
	{
		cart_total=rs1.getInt(5);  //in database total is on 5th row
		cart_total = cart_total+product_total;
		quantity=rs1.getInt(3);		// quantity is in 3rd place in our db
		quantity = quantity+1;
		z=1; // (case:1) we already have the product so we cannot insert again so we will icrement its quantity and get total.
	}
	if(z==1)  //update the value for above case1 and send response to home page
	{
		st.executeUpdate("update cart set total='"+cart_total+"',quantity='"+quantity+"' where product_id='"+product_id+"' and email='"+email+"' and address is NULL");
		response.sendRedirect("home.jsp?msg=exist");
	}
	if(z==0)  // if z==0 we dont have that product in out cart, so we insert it in out cart
	{
		PreparedStatement ps = con.prepareStatement("insert into cart(email,product_id,quantity,price,total)values(?,?,?,?,?)");
		ps.setString(1,email);
		ps.setString(2,product_id);
		ps.setInt(3,quantity);
		ps.setInt(4,product_price);
		ps.setInt(5,product_total);
		ps.executeUpdate();
		response.sendRedirect("home.jsp?msg=added");
	}
}
catch(Exception e)
{
	System.out.println(e);
	response.sendRedirect("home.jsp?msg=invalid");
}
%>