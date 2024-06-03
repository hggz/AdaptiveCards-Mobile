/* ----------------------------------------------------------------------------
 * This file was automatically generated by SWIG (http://www.swig.org).
 * Version 4.0.2
 *
 * Do not make changes to this file unless you know what you are doing--modify
 * the SWIG interface file instead.
 * ----------------------------------------------------------------------------- */

package io.adaptivecards.objectmodel;

public class ActionSetParser extends BaseCardElementParser {
  private transient long swigCPtr;
  private transient boolean swigCMemOwnDerived;

  protected ActionSetParser(long cPtr, boolean cMemoryOwn) {
    super(AdaptiveCardObjectModelJNI.ActionSetParser_SWIGSmartPtrUpcast(cPtr), true);
    swigCMemOwnDerived = cMemoryOwn;
    swigCPtr = cPtr;
  }

  protected static long getCPtr(ActionSetParser obj) {
    return (obj == null) ? 0 : obj.swigCPtr;
  }

  protected void swigSetCMemOwn(boolean own) {
    swigCMemOwnDerived = own;
    super.swigSetCMemOwn(own);
  }

  @SuppressWarnings("deprecation")
  protected void finalize() {
    delete();
  }

  public synchronized void delete() {
    if (swigCPtr != 0) {
      if (swigCMemOwnDerived) {
        swigCMemOwnDerived = false;
        AdaptiveCardObjectModelJNI.delete_ActionSetParser(swigCPtr);
      }
      swigCPtr = 0;
    }
    super.delete();
  }

  public ActionSetParser() {
    this(AdaptiveCardObjectModelJNI.new_ActionSetParser__SWIG_0(), true);
  }

  public ActionSetParser(ActionSetParser arg0) {
    this(AdaptiveCardObjectModelJNI.new_ActionSetParser__SWIG_1(ActionSetParser.getCPtr(arg0), arg0), true);
  }

  public BaseCardElement Deserialize(ParseContext context, JsonValue root) {
    long cPtr = AdaptiveCardObjectModelJNI.ActionSetParser_Deserialize(swigCPtr, this, ParseContext.getCPtr(context), context, JsonValue.getCPtr(root), root);
    return (cPtr == 0) ? null : new BaseCardElement(cPtr, true);
  }

  public BaseCardElement DeserializeFromString(ParseContext contexts, String jsonString) {
    long cPtr = AdaptiveCardObjectModelJNI.ActionSetParser_DeserializeFromString(swigCPtr, this, ParseContext.getCPtr(contexts), contexts, jsonString);
    return (cPtr == 0) ? null : new BaseCardElement(cPtr, true);
  }

}
