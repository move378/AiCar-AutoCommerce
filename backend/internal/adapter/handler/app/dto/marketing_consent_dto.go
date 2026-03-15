package dto

type MarketingConsentRequest struct {
	DeviceID        string `json:"device_id" binding:"required"`
	MarketingAgreed bool   `json:"marketing_agreed"`
}

type MarketingConsentResponse struct {
	Status  int    `json:"status"`
	Message string `json:"message"`
}
