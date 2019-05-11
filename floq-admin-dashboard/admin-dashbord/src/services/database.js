export const REF_FLPHOTOS = "FLPHOTOS";
export const REF_TOKENS = "FLTOKENS";
export const REF_USERS = "FLUSER";
export const FIELD_CLIQ_ID = "cliqID";
export const FIELD_FLAGGED = "flagged";
export const FIELD_FLAGGERS = "flaggers";
export const REF_PHOTOBUCKET = "FLFloqPhotos";

export const exctractCliqName = cliqID => {
  const split = cliqID.split("-");
  if (split.lenght > 0) {
    return split[0].trim();
  } else {
    return "Unknown";
  }
};
