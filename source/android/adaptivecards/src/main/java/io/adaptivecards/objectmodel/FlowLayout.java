/* ----------------------------------------------------------------------------
 * This file was automatically generated by SWIG (http://www.swig.org).
 * Version 4.0.2
 *
 * Do not make changes to this file unless you know what you are doing--modify
 * the SWIG interface file instead.
 * ----------------------------------------------------------------------------- */

package io.adaptivecards.objectmodel;

public class FlowLayout extends Layout {
  private transient long swigCPtr;
  private transient boolean swigCMemOwnDerived;

  protected FlowLayout(long cPtr, boolean cMemoryOwn) {
    super(AdaptiveCardObjectModelJNI.FlowLayout_SWIGSmartPtrUpcast(cPtr), true);
    swigCMemOwnDerived = cMemoryOwn;
    swigCPtr = cPtr;
  }

  protected static long getCPtr(FlowLayout obj) {
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
        AdaptiveCardObjectModelJNI.delete_FlowLayout(swigCPtr);
      }
      swigCPtr = 0;
    }
    super.delete();
  }

  public FlowLayout() {
    this(AdaptiveCardObjectModelJNI.new_FlowLayout__SWIG_0(), true);
  }

  public FlowLayout(FlowLayout arg0) {
    this(AdaptiveCardObjectModelJNI.new_FlowLayout__SWIG_1(FlowLayout.getCPtr(arg0), arg0), true);
  }

  public ItemFit GetItemFit() {
    return ItemFit.swigToEnum(AdaptiveCardObjectModelJNI.FlowLayout_GetItemFit(swigCPtr, this));
  }

  public void setItemFit(ItemFit value) {
    AdaptiveCardObjectModelJNI.FlowLayout_setItemFit(swigCPtr, this, value.swigValue());
  }

  public SWIGTYPE_p_std__optionalT_std__string_t GetItemWidth() {
    return new SWIGTYPE_p_std__optionalT_std__string_t(AdaptiveCardObjectModelJNI.FlowLayout_GetItemWidth(swigCPtr, this), true);
  }

  public void SetItemWidth(SWIGTYPE_p_std__optionalT_std__string_t value) {
    AdaptiveCardObjectModelJNI.FlowLayout_SetItemWidth(swigCPtr, this, SWIGTYPE_p_std__optionalT_std__string_t.getCPtr(value));
  }

  public int GetItemPixelWidth() {
    return AdaptiveCardObjectModelJNI.FlowLayout_GetItemPixelWidth(swigCPtr, this);
  }

  public void SetItemPixelWidth(int value) {
    AdaptiveCardObjectModelJNI.FlowLayout_SetItemPixelWidth(swigCPtr, this, value);
  }

  public int GetMinItemPixelWidth() {
    return AdaptiveCardObjectModelJNI.FlowLayout_GetMinItemPixelWidth(swigCPtr, this);
  }

  public void SetMinItemPixelWidth(int value) {
    AdaptiveCardObjectModelJNI.FlowLayout_SetMinItemPixelWidth(swigCPtr, this, value);
  }

  public int GetMaxItemPixelWidth() {
    return AdaptiveCardObjectModelJNI.FlowLayout_GetMaxItemPixelWidth(swigCPtr, this);
  }

  public void SetMaxItemPixelWidth(int value) {
    AdaptiveCardObjectModelJNI.FlowLayout_SetMaxItemPixelWidth(swigCPtr, this, value);
  }

  public SWIGTYPE_p_std__optionalT_std__string_t GetMinItemWidth() {
    return new SWIGTYPE_p_std__optionalT_std__string_t(AdaptiveCardObjectModelJNI.FlowLayout_GetMinItemWidth(swigCPtr, this), true);
  }

  public void SetMinItemWidth(SWIGTYPE_p_std__optionalT_std__string_t value) {
    AdaptiveCardObjectModelJNI.FlowLayout_SetMinItemWidth(swigCPtr, this, SWIGTYPE_p_std__optionalT_std__string_t.getCPtr(value));
  }

  public SWIGTYPE_p_std__optionalT_std__string_t GetMaxItemWidth() {
    return new SWIGTYPE_p_std__optionalT_std__string_t(AdaptiveCardObjectModelJNI.FlowLayout_GetMaxItemWidth(swigCPtr, this), true);
  }

  public void SetMaxItemWidth(SWIGTYPE_p_std__optionalT_std__string_t value) {
    AdaptiveCardObjectModelJNI.FlowLayout_SetMaxItemWidth(swigCPtr, this, SWIGTYPE_p_std__optionalT_std__string_t.getCPtr(value));
  }

  public Spacing GetColumnSpacing() {
    return Spacing.swigToEnum(AdaptiveCardObjectModelJNI.FlowLayout_GetColumnSpacing(swigCPtr, this));
  }

  public void SetColumnSpacing(Spacing value) {
    AdaptiveCardObjectModelJNI.FlowLayout_SetColumnSpacing(swigCPtr, this, value.swigValue());
  }

  public Spacing GetRowSpacing() {
    return Spacing.swigToEnum(AdaptiveCardObjectModelJNI.FlowLayout_GetRowSpacing(swigCPtr, this));
  }

  public void SetRowSpacing(Spacing value) {
    AdaptiveCardObjectModelJNI.FlowLayout_SetRowSpacing(swigCPtr, this, value.swigValue());
  }

  public HorizontalAlignment GetHorizontalAlignment() {
    return HorizontalAlignment.swigToEnum(AdaptiveCardObjectModelJNI.FlowLayout_GetHorizontalAlignment(swigCPtr, this));
  }

  public void SetHorizontalAlignment(HorizontalAlignment value) {
    AdaptiveCardObjectModelJNI.FlowLayout_SetHorizontalAlignment(swigCPtr, this, value.swigValue());
  }

  public boolean ShouldSerialize() {
    return AdaptiveCardObjectModelJNI.FlowLayout_ShouldSerialize(swigCPtr, this);
  }

  public String Serialize() {
    return AdaptiveCardObjectModelJNI.FlowLayout_Serialize(swigCPtr, this);
  }

  public JsonValue SerializeToJsonValue() {
    return new JsonValue(AdaptiveCardObjectModelJNI.FlowLayout_SerializeToJsonValue(swigCPtr, this), true);
  }

  public static FlowLayout Deserialize(JsonValue json) {
    long cPtr = AdaptiveCardObjectModelJNI.FlowLayout_Deserialize(JsonValue.getCPtr(json), json);
    return (cPtr == 0) ? null : new FlowLayout(cPtr, true);
  }

  public static FlowLayout DeserializeFromString(String jsonString) {
    long cPtr = AdaptiveCardObjectModelJNI.FlowLayout_DeserializeFromString(jsonString);
    return (cPtr == 0) ? null : new FlowLayout(cPtr, true);
  }

  public static FlowLayout dynamic_cast(Layout layout) {
    long cPtr = AdaptiveCardObjectModelJNI.FlowLayout_dynamic_cast(Layout.getCPtr(layout), layout);
    return (cPtr == 0) ? null : new FlowLayout(cPtr, true);
  }

}
