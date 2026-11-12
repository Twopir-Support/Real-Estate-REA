import { LightningElement, api } from 'lwc';
import { formatValue } from 'c/tcUtils';

/**
 * Lightweight horizontal bar chart (no external library).
 * series: [{ label, value }], format: currency | number | percent | text.
 * For percent, values are whole percentages (e.g. 92.5).
 */
export default class TcChart extends LightningElement {
    @api title;
    @api format = 'number';
    @api color = '#0F5F74';
    @api emptyMessage = 'No data yet.';
    @api maxValue; // optional fixed scale (e.g. 100 for percentages)
    _series = [];

    @api
    get series() {
        return this._series;
    }
    set series(value) {
        this._series = Array.isArray(value) ? value : [];
    }

    get hasData() {
        return this._series.some((s) => Number(s.value) > 0);
    }

    get rows() {
        const max = this.maxValue ? Number(this.maxValue) : Math.max(...this._series.map((s) => Number(s.value) || 0), 0);
        return this._series.map((s, i) => {
            const v = Number(s.value) || 0;
            const pct = max > 0 ? Math.max(0, Math.min(100, (v / max) * 100)) : 0;
            const display = this.format === 'percent' ? `${v.toFixed(1)}%` : formatValue(v, this.format, true);
            return {
                key: `${s.label}-${i}`,
                label: s.label,
                display,
                barStyle: `width:${pct.toFixed(1)}%;background:${this.color};`,
                title: `${s.label}: ${display}`
            };
        });
    }
}
