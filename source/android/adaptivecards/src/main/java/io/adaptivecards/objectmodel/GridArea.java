/* ----------------------------------------------------------------------------
 * This file was automatically generated by SWIG (http://www.swig.org).
 * Version 4.0.2
 *
 * Do not make changes to this file unless you know what you are doing--modify
 * the SWIG interface file instead.
 * ----------------------------------------------------------------------------- */

package io.adaptivecards.objectmodel;

public class GridArea {
  private transient long swigCPtr;
  private transient boolean swigCMemOwn;

  protected GridArea(long cPtr, boolean cMemoryOwn) {
    swigCMemOwn = cMemoryOwn;
    swigCPtr = cPtr;
  }

  protected static long getCPtr(GridArea obj) {
    return (obj == null) ? 0 : obj.swigCPtr;
  }

  protected void swigSetCMemOwn(boolean own) {
    swigCMemOwn = own;
  }

  @SuppressWarnings("deprecation")
  protected void finalize() {
    delete();
  }

  public synchronized void delete() {
    if (swigCPtr != 0) {
      if (swigCMemOwn) {
        swigCMemOwn = false;
        AdaptiveCardObjectModelJNI.delete_GridArea(swigCPtr);
      }
      swigCPtr = 0;
    }
  }

  public GridArea() {
    this(AdaptiveCardObjectModelJNI.new_GridArea(), true);
  }

  public String GetName() {
    return AdaptiveCardObjectModelJNI.GridArea_GetName(swigCPtr, this);
  }

  public void SetName(String value) {
    AdaptiveCardObjectModelJNI.GridArea_SetName(swigCPtr, this, value);
  }

  public int GetRow() {
    return AdaptiveCardObjectModelJNI.GridArea_GetRow(swigCPtr, this);
  }

  public void SetRow(int value) {
    AdaptiveCardObjectModelJNI.GridArea_SetRow(swigCPtr, this, value);
  }

  public int GetRowSpan() {
    return AdaptiveCardObjectModelJNI.GridArea_GetRowSpan(swigCPtr, this);
  }

  public void SetRowSpan(int value) {
    AdaptiveCardObjectModelJNI.GridArea_SetRowSpan(swigCPtr, this, value);
  }

  public int GetColumn() {
    return AdaptiveCardObjectModelJNI.GridArea_GetColumn(swigCPtr, this);
  }

  public void SetColumn(int value) {
    AdaptiveCardObjectModelJNI.GridArea_SetColumn(swigCPtr, this, value);
  }

  public int GetColumnSpan() {
    return AdaptiveCardObjectModelJNI.GridArea_GetColumnSpan(swigCPtr, this);
  }

  public void SetColumnSpan(int value) {
    AdaptiveCardObjectModelJNI.GridArea_SetColumnSpan(swigCPtr, this, value);
  }

  public boolean ShouldSerialize() {
    return AdaptiveCardObjectModelJNI.GridArea_ShouldSerialize(swigCPtr, this);
  }

  public String Serialize() {
    return AdaptiveCardObjectModelJNI.GridArea_Serialize(swigCPtr, this);
  }

  public JsonValue SerializeToJsonValue() {
    return new JsonValue(AdaptiveCardObjectModelJNI.GridArea_SerializeToJsonValue(swigCPtr, this), true);
  }

  public static GridArea Deserialize(JsonValue json) {
    long cPtr = AdaptiveCardObjectModelJNI.GridArea_Deserialize(JsonValue.getCPtr(json), json);
    return (cPtr == 0) ? null : new GridArea(cPtr, true);
  }

  public static GridArea DeserializeFromString(String jsonString) {
    long cPtr = AdaptiveCardObjectModelJNI.GridArea_DeserializeFromString(jsonString);
    return (cPtr == 0) ? null : new GridArea(cPtr, true);
  }

}
