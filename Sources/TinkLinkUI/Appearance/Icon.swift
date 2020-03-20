import UIKit

enum Icon {
    case bankID
    case password
    case profile
    case warning

    fileprivate var base64Encoded: String {
        switch self {
        case .bankID:
            return "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"
        case .password:
            return "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"
        case .profile:
            return "iVBORw0KGgoAAAANSUhEUgAAAFcAAABUCAYAAAD3XKvCAAAAAXNSR0IArs4c6QAAAGxlWElmTU0AKgAAAAgABAEaAAUAAAABAAAAPgEbAAUAAAABAAAARgEoAAMAAAABAAIAAIdpAAQAAAABAAAATgAAAAAAAADYAAAAAQAAANgAAAABAAKgAgAEAAAAAQAAAFegAwAEAAAAAQAAAFQAAAAAMP+WqgAAAAlwSFlzAAAhOAAAITgBRZYxYAAAABxpRE9UAAAAAgAAAAAAAAAqAAAAKAAAACoAAAAqAAADWPWx7ysAAAMkSURBVHgB7Jq9r0xRFMUfEiLofEQ0HoqHSMQrNBRPIzoRFAoNGgmJoJCQ0BDxHyheRAQloaBQiEiESGjoqDRaIj6ej/VLZhqZvc/cueeeO2fm7GRlJvecs9fa696Zu+/HxESJ4kBxoDhQHCgOFAeKAzk7sETiNwq7hEPC6Q74PiNMCYuFEn06sEbzjguPhZ/C3wC+a/yhcExYJZTo4cAObXsq/BFChlrjv7WWnTItlJAD/OzvCZZhg2xnB90R1gljGxdU+ZwwiIH9rOFv5dS4uctJ6G6Dpv5v/Ky4Fo6DyatV5KuExnaNfi7OFaNsMEfs6wGM/aw1b4VHHfCdbV3j+v18oTWLhJEMTjJVjKCv3eA4wRhzMK3fvDedfNkOnevTgC+aR89aNVjD2n5MPls1+TDP3yxx9KChwulzJ2sUwlpyhHjoUDbV4BmqpQ8CBXOVxc97fgTV5CAXOT2T70fgaj3FzkCRNPz7G1BJztDVHleFWQctkHcEnW+wOnJ73GjLNjibe8Vxlm8y5il5qJPwupEmtdXOfUYZPHP5y2g6Qn9LaMwynkm1ZS53r1IFXJYONGYXXGp67dfRhBXBZZmLxuUJtUSh4kzsFZTyxjZc3o7Orms44Jj7Psruq5YETmtnozWrOCm1VjFPWqgETksPWrOKK1JrFXOrhUrgtPSgNau4JrVWMTdaqAROS8/VFvTUouT63iqG+7KpA05Lz4nUYury8W6BVQw3u1MHnJaevanF1OWbcYrhjtXSugQV1i/TXO8u2XSFXEMxda1UWEcK21O2P15biJaVQnbxTootg3nkkyq8x0sfUomIzXNZCS1z5zQ2FZuwRz44fgmWjks91mSxabtTFMXypk3TEXqbZ33TAprKz/3Uj4J11LD9YFPkndwed9Y3y/HtsOAV+E3j25gYOchJbo/7SGTO5Ol4YOj1mBT/SdgaURm5yOkZ+1LjCyJytpZqT6BQTPgq7IugkBzk8ozlBb0tEbiGJoXXDnWN4GntbWFyANWsYW3oiS9cF4WRiirvif1Q5deF3YL3diJjzGEua7o7yft8o3leTg3HiX8AAAD//6Izt6UAAANpSURBVO2aS6hNURjHr2cipbzL40qiUIRCyugqppIkDEyMvG6uJN2bAZIkAzHANRADEzG4lGukpLzJxcAAueoOhOTN76u7uvvs1ll7r7PWfp2zv/q3916P7//9/2efs9fe+zQ1pRtToPsA/lngM2O7wUVwrB+yL23SZ5PrOeMngrqNxSj7CGxM8TH2KZwT6tbVgLBp7D8EPkyLk+MxXOMC/HW/OwqFV0Acc1zH9MCzCQwBDRVrUfsSuBoYZ/4reDaDhjJ5KIK3AduLXRxDdWNewyUfakPFcNSuAqfAO6AzxmebrDrGgIaLQSheCNaB7eAQOA+6wBPQB/4CV7PlQ2wBZYQckDN9OlgO9oMHoFazTzB3MCjD4MAM+lrBHWB7Zl9mzjBQRgwH5jHmOrA5m68xfkSM3OWQfgdWsr0L4pp8i7GyDs88xlNBc+ZVxCtAll9vQRyTbzIu8/WwfO16wSJQhJAHN/J7HMfgo1kK2hEo8gv7q7MsxoJbVhnnQByD11vk9TZ0AZm+hwr8xfFWbwzJJ9oFxW9gMvkr/fOTL2WAQX7s5WFItaI6Bobmfm+jQYfSJ1rlbE8lzsCiiHXbP/TPTaUSPySHI/SIxj1+qMxZZtMt5ulMVW3yxqBIIXdmsr5V9eu28tZjUtKiLkQUIa9SirgIH03dUrvOWNXWSX9iMZPMpguAXNCKsiTTmTSLxvBFWhkrW7mdXqKb6KPtLEmCZOH9dh8kGec4HqHxUhL1NZP0p4H4Pn3y0LvoMRYBn0D4xFHHP+jz/j5OHskpAt12A/31EvsQotOo2lp9C31jIJRPuogXsWoejaTjvUGvrHu9xRwyqU9Ntz3tjSk/iXZHaF7hq1S5TdSZqtqW+iLKUZ6pEZoP+qr1hoHohS+SHOa5Z9B920e98vtjWvvt9UGS0xyiTX07w9tv9Dk/b1hjIBDCbiD/nEkLUKUWclMRNjV4vMy1kp0RBEGyNPZd9djOf2bQ32abLDz+iCF5GmaGOcL1JX0s38hwDepYHrg7RSezVbI8bJ3E1DD5pEH/1RryVUzpMiTPwuyK4lI4MN2tybs4p3jE7CxMrMbpJKaGyVsM+ntqyFcxpdeQvJoBSbZXFJfCQYtBf58r/wEStOcIrnps509mQkcViDdllA6UDpQOlA6UDtS3A/8BsyvHAJofvScAAAAASUVORK5CYII="
        case .warning:
            return "iVBORw0KGgoAAAANSUhEUgAAACAAAAAsCAYAAAAEuLqPAAAAAXNSR0IArs4c6QAAAHhlWElmTU0AKgAAAAgABAEaAAUAAAABAAAAPgEbAAUAAAABAAAARgEoAAMAAAABAAIAAIdpAAQAAAABAAAATgAAAAAAAACQAAAAAQAAAJAAAAABAAOgAQADAAAAAQABAACgAgAEAAAAAQAAACCgAwAEAAAAAQAAACwAAAAAu/s3UwAAAAlwSFlzAAAWJQAAFiUBSVIk8AAAABxpRE9UAAAAAgAAAAAAAAAWAAAAKAAAABYAAAAWAAAAhFHHh4AAAABQSURBVFgJYvi/XiXs/3rlSahYJYyBygCnPf/XK037t07pPzIGiVHZfgac9uCUoLILcNqDU2LUAaMhMBoCoyEwGgKjITAaAqMhMBoCdAoBAAAAAP//RA9R2QAAAElJREFUY/i/Xmnav3VK/5ExSIyBygCnPTglRh0wGgKjITAaAqMhMBoCoyEwGgKjIUC3ENhszPV/i64gCgaKUdl+hv90sodkdwMAKoNTSOUrCckAAAAASUVORK5CYII="
        }
    }
}

extension UIImage {
    convenience init?(icon: Icon) {
        guard let data = Data(base64Encoded: icon.base64Encoded)
            else { return nil }
        self.init(data: data)
    }
}