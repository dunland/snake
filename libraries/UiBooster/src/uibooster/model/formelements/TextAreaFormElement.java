package uibooster.model.formelements;

import uibooster.model.FormElement;
import uibooster.model.FormElementChangeListener;

import javax.swing.*;
import java.awt.event.KeyAdapter;
import java.awt.event.KeyEvent;

public class TextAreaFormElement extends FormElement {

    private final JTextArea area;

    public TextAreaFormElement(String label, int rows, String initialText, boolean readOnly) {
        super(label);
        area = new JTextArea(initialText);
        area.setEditable(!readOnly);
        area.setRows(rows);
    }

    @Override
    public JComponent createComponent(FormElementChangeListener changeListener) {

        if (changeListener != null) {
            area.addKeyListener(new KeyAdapter() {
                @Override
                public void keyReleased(KeyEvent e) {
                    super.keyReleased(e);
                    changeListener.onChange(TextAreaFormElement.this, getValue());
                }
            });
        }
        return new JScrollPane(area);
    }

    @Override
    public void setEnabled(boolean enable) {
        area.setEnabled(enable);
    }

    @Override
    public String getValue() {
        return area.getText();
    }

    @Override
    public void setValue(Object value) {
        area.setText(value.toString());
    }
}