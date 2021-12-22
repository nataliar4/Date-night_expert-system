import javax.swing.*; 
import javax.swing.border.*; 
import javax.swing.table.*;
import java.awt.*; 
import java.awt.event.*; 

import java.text.BreakIterator;

import java.util.Locale;
import java.util.ResourceBundle;
import java.util.MissingResourceException;
 
import CLIPSJNI.*;

class Dates implements ActionListener {  
  JLabel displayLabel;
  JButton nextButton;
  JButton prevButton;
  JPanel choicesPanel;
  ButtonGroup choicesButtons;
  ResourceBundle autoResources;

  Environment clips;
  boolean isExecuting = false;
  Thread executionThread;
    
  Dates() {  
	try { 
		UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
	} catch (Exception e) {
	    e.printStackTrace();
	}
    try {
      this.autoResources = ResourceBundle.getBundle("resources.DatesResources", Locale.getDefault());
    } catch (MissingResourceException mre) {
      mre.printStackTrace();
      return;
    }
    
    /*================================*/
    /* Create a new JFrame container. */
    /*================================*/
    
    JFrame frame = new JFrame(autoResources.getString("Dates"));  

    /*=============================*/
    /* Specify FlowLayout manager. */
    /*=============================*/
      
    frame.getContentPane().setLayout(new GridLayout(3,1));  

    /*=================================*/
    /* Give the frame an initial size. */
    /*=================================*/
    
    frame.setSize(350,200);  

    /*=============================================================*/
    /* Terminate the program when the user closes the application. */
    /*=============================================================*/
    
    frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);  

    /*===========================*/
    /* Create the display panel. */
    /*===========================*/
    
    JPanel displayPanel = new JPanel(); 
    this.displayLabel = new JLabel();
    displayPanel.add(this.displayLabel);
    
    /*===========================*/
    /* Create the choices panel. */
    /*===========================*/
    
    this.choicesPanel = new JPanel(); 
    this.choicesButtons = new ButtonGroup();
    
    /*===========================*/
    /* Create the buttons panel. */
    /*===========================*/

    JPanel buttonPanel = new JPanel(); 
    
    this.prevButton = new JButton(this.autoResources.getString("Prev"));
    prevButton.setActionCommand("Prev");
    buttonPanel.add(this.prevButton);
    prevButton.addActionListener(this);
    
    this.nextButton = new JButton(this.autoResources.getString("Next"));
    nextButton.setActionCommand("Next");
    buttonPanel.add(this.nextButton);
    nextButton.addActionListener(this);
    
    /*=====================================*/
    /* Add the panels to the content pane. */
    /*=====================================*/
    
    frame.getContentPane().add(displayPanel); 
    frame.getContentPane().add(this.choicesPanel); 
    frame.getContentPane().add(buttonPanel); 

    /*========================*/
    /* Load the auto program. */
    /*========================*/
    
    this.clips = new Environment();
    
    this.clips.load("dates.clp");
    
    this.clips.reset();
    this.runAuto();

    /*====================*/
    /* Display the frame. */
    /*====================*/

    frame.setLocationRelativeTo(null);

    /*====================*/
    /* Display the frame. */
    /*====================*/
    
    frame.setVisible(true);  
  }  

  /****************/
  /* nextUIState: */
  /****************/  
  private void nextUIState() throws Exception
    {
    /*=====================*/
    /* Get the state-list. */
    /*=====================*/
    
    String evalStr = "(find-all-facts ((?f state-list)) TRUE)";
    
    String currentID = clips.eval(evalStr).get(0).getFactSlot("current").toString();

    /*===========================*/
    /* Get the current UI state. */
    /*===========================*/
    
    evalStr = "(find-all-facts ((?f UI-state)) " +
                              "(eq ?f:id " + currentID + "))";
    
    PrimitiveValue fv = this.clips.eval(evalStr).get(0);
    
    /*========================================*/
    /* Determine the Next/Prev button states. */
    /*========================================*/
    
    if (fv.getFactSlot("state").toString().equals("final")) { 
      nextButton.setActionCommand("Restart");
      nextButton.setText(autoResources.getString("Restart")); 
      prevButton.setVisible(true);
    } else if (fv.getFactSlot("state").toString().equals("initial")) {
      nextButton.setActionCommand("Next");
      nextButton.setText(autoResources.getString("Next"));
      prevButton.setVisible(false);
    } else { 
      nextButton.setActionCommand("Next");
      nextButton.setText(autoResources.getString("Next"));
      prevButton.setVisible(true);
    }
    
    /*=====================*/
    /* Set up the choices. */
    /*=====================*/
    
    this.choicesPanel.removeAll();
    this.choicesButtons = new ButtonGroup();
          
    PrimitiveValue pv = fv.getFactSlot("valid-answers");
    
    String selected = fv.getFactSlot("response").toString();
    
    for (int i = 0; i < pv.size(); i++)  {
      PrimitiveValue bv = pv.get(i);
      JRadioButton rButton;
                    
      if (bv.toString().equals(selected)) { 
        rButton = new JRadioButton(autoResources.getString(bv.toString()), true); 
      } else { 
        rButton = new JRadioButton(autoResources.getString(bv.toString()), false); 
      }
                  
      rButton.setActionCommand(bv.toString());
      this.choicesPanel.add(rButton);
      this.choicesButtons.add(rButton);
      }
      
    this.choicesPanel.repaint();
    
    /*====================================*/
    /* Set the label to the display text. */
    /*====================================*/

    String theText = autoResources.getString(fv.getFactSlot("display").symbolValue());
          
    wrapLabelText(this.displayLabel, theText);
    
    this.executionThread = null;
    
    this.isExecuting = false;
  }

  /*########################*/
  /* ActionListener Methods */
  /*########################*/

  public void actionPerformed(ActionEvent ae) { 
    try { 
      this.onActionPerformed(ae); 
    } catch (Exception e) { 
      e.printStackTrace(); 
    }
  }

  public void runAuto() {
    Runnable runThread = new Runnable() {
      public void run() {
        clips.run();
        
        SwingUtilities.invokeLater(new Runnable() {
          public void run() {
            try { 
              nextUIState(); 
            } catch (Exception e) { 
              e.printStackTrace(); 
            }
          }
        });
      }
    };
    
    this.isExecuting = true;
    
    this.executionThread = new Thread(runThread);
    
    this.executionThread.start();
  }
  
  public void onActionPerformed(ActionEvent ae) throws Exception { 
    if (this.isExecuting) return;
    
    /*=====================*/
    /* Get the state-list. */
    /*=====================*/
    
    String evalStr = "(find-all-facts ((?f state-list)) TRUE)";
    
    String currentID = clips.eval(evalStr).get(0).getFactSlot("current").toString();

    /*=========================*/
    /* Handle the Next button. */
    /*=========================*/
    
    if (ae.getActionCommand().equals("Next")) {
      if (this.choicesButtons.getButtonCount() == 0) { 
        this.clips.assertString("(next " + currentID + ")"); 
      } else {
        this.clips.assertString("(next " + currentID + " " +
                            choicesButtons.getSelection().getActionCommand() + 
                            ")");
      }
        
      this.runAuto();
    } else if (ae.getActionCommand().equals("Restart")) { 
      this.clips.reset(); 
      this.runAuto();
    } else if (ae.getActionCommand().equals("Prev")) {
      this.clips.assertString("(prev " + currentID + ")");
      this.runAuto();
    }
  }
  
  private void wrapLabelText(JLabel label, String text) {
    FontMetrics fm = label.getFontMetrics(label.getFont());
    Container container = label.getParent();
    int containerWidth = container.getWidth();
    int textWidth = SwingUtilities.computeStringWidth(fm, text);
    int desiredWidth;

    if (textWidth <= containerWidth) { 
      desiredWidth = containerWidth; 
    } else { 
      int lines = (int) ((textWidth + containerWidth) / containerWidth);
              
      desiredWidth = (int) (textWidth / lines);
    }
                
    BreakIterator boundary = BreakIterator.getWordInstance();
    boundary.setText(text);
  
    StringBuffer trial = new StringBuffer();
    StringBuffer real = new StringBuffer("<html><center>");
  
    int start = boundary.first();
    for (int end = boundary.next(); end != BreakIterator.DONE;
          start = end, end = boundary.next()) {
      String word = text.substring(start,end);
      trial.append(word);
      int trialWidth = SwingUtilities.computeStringWidth(fm,trial.toString());
      if (trialWidth > containerWidth) {
        trial = new StringBuffer(word);
        real.append("<br>");
        real.append(word);
      } else if (trialWidth > desiredWidth) {
        trial = new StringBuffer("");
        real.append(word);
        real.append("<br>");
      } else { 
        real.append(word); 
      }
    }
  
    real.append("</html>");
  
    label.setText(real.toString());
  }
    
  public static void main(String args[]) {  
    // Create the frame on the event dispatching thread.  
    SwingUtilities.invokeLater(new Runnable() {  
      public void run() { 
        new Dates(); 
      }  
    });   
  }  
}