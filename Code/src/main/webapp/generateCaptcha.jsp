<%@ page import="java.awt.*, java.awt.image.BufferedImage, java.io.*, javax.imageio.ImageIO, javax.servlet.*" %>
<%
    int width = 150;
    int height = 50;
    char data[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789".toCharArray();
    String captcha = "";
    for (int i = 0; i < 6; i++) {
        captcha += data[(int) (Math.random() * data.length)];
    }
    session.setAttribute("captcha", captcha);
    
    BufferedImage image = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
    Graphics g = image.getGraphics();
    g.setColor(Color.LIGHT_GRAY);
    g.fillRect(0, 0, width, height);
    g.setColor(Color.BLACK);
    g.setFont(new Font("Arial", Font.BOLD, 26));
    g.drawString(captcha, 25, 35);
    g.dispose();
    
    response.setContentType("image/png");
    OutputStream os = response.getOutputStream();
    ImageIO.write(image, "png", os);
    os.close();
%>
