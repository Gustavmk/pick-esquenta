import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

export let errorRate = new Rate('errors');

export let options = {
    stages: [
        { duration: '5m', target: 1000 },
    ],
    thresholds: {
        errors: ['rate<0.01'], // <1% errors
    },
};

export default function () {
    let res = http.get('http://nginx.default.svc.cluster.local');
    let success = check(res, {
        'status is 200': (r) => r.status === 200,
    });
    errorRate.add(!success);
    sleep(1);
}
