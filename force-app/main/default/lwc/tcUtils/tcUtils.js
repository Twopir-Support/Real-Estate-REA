// Shared formatting and error helpers for TC Lightning Web Components.

const LOCALE = 'en-US';

export function formatCurrency(value, compact = false) {
    if (value === null || value === undefined || value === '') return '—';
    const n = Number(value);
    if (compact && Math.abs(n) >= 1000) {
        return new Intl.NumberFormat(LOCALE, { style: 'currency', currency: 'USD', notation: 'compact', maximumFractionDigits: 1 }).format(n);
    }
    return new Intl.NumberFormat(LOCALE, { style: 'currency', currency: 'USD', maximumFractionDigits: Math.abs(n) < 100 ? 2 : 0 }).format(n);
}

export function formatNumber(value, compact = false) {
    if (value === null || value === undefined || value === '') return '—';
    const n = Number(value);
    return new Intl.NumberFormat(LOCALE, compact && Math.abs(n) >= 10000 ? { notation: 'compact', maximumFractionDigits: 1 } : { maximumFractionDigits: 0 }).format(n);
}

/** value is a fraction (0.25 = 25%). */
export function formatPercent(value, digits = 1) {
    if (value === null || value === undefined || value === '') return '—';
    return new Intl.NumberFormat(LOCALE, { style: 'percent', minimumFractionDigits: digits, maximumFractionDigits: digits }).format(Number(value));
}

export function formatValue(value, format, compact = false) {
    switch (format) {
        case 'currency': return formatCurrency(value, compact);
        case 'percent': return formatPercent(value);
        case 'number': return formatNumber(value, compact);
        default: return value === null || value === undefined ? '—' : String(value);
    }
}

export function formatDate(value) {
    if (!value) return '—';
    const d = new Date(value + (String(value).length === 10 ? 'T00:00:00' : ''));
    return new Intl.DateTimeFormat(LOCALE, { year: 'numeric', month: 'short', day: 'numeric' }).format(d);
}

/** Turns Apex/LDS errors into a readable message. */
export function reduceErrors(error) {
    if (!error) return 'Unknown error';
    const errors = Array.isArray(error) ? error : [error];
    return errors
        .map((e) => {
            if (typeof e === 'string') return e;
            if (e.body) {
                if (Array.isArray(e.body)) return e.body.map((b) => b.message).join(', ');
                if (e.body.output && e.body.output.errors && e.body.output.errors.length) return e.body.output.errors.map((x) => x.message).join(', ');
                if (e.body.output && e.body.output.fieldErrors) {
                    const fe = Object.values(e.body.output.fieldErrors).flat().map((x) => x.message);
                    if (fe.length) return fe.join(', ');
                }
                if (e.body.message) return e.body.message;
            }
            return e.message || JSON.stringify(e);
        })
        .filter(Boolean)
        .join('; ');
}

/** Colour for a lease expiration year in the stacking plan (nearer years are warmer). */
export function expirationColor(year) {
    const palette = ['#C23934', '#E4A201', '#5FA8D3', '#2E8B57', '#1B5E7A', '#6A4C93', '#3D5A80'];
    if (!year) return '#7B8A93';
    const offset = Number(year) - new Date().getFullYear();
    if (offset < 0) return '#8E1B17';
    return palette[Math.min(offset, palette.length - 1)];
}
