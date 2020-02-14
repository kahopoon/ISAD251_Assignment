using System;
namespace OrderApplication.Models
{
    public enum Error
    {
        MISSING_NAME            = 1001,
        MISSING_EMAIL           = 1002,
        MISSING_PASSWORD        = 1003,
        MISSING_TYPE            = 1004,
        MISSING_DESCRIPTION     = 1005,
        MISSING_IMAGE_PATH      = 1006,
        MISSING_STATUS          = 1007,
        MISSING_ORDER_PRODUCT   = 1008,
        MISSING_QUANTITY        = 1009,
        MISSING_ORDER_ID        = 1010,

        DUPLICATED_EMAIL        = 2001,

        INVALID_TOKEN           = 3001,
        INVALID_PASSWORD        = 3002,

        EXPIRED_TOKEN           = 4001,

        PRODUCT_NOT_FOUND       = 5001,
        ORDER_NOT_FOUND         = 5002,

        ORDER_IN_PROGRESS       = 6001,
    }
}
